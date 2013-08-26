//
//  DNPinchToZoomListViewController.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNPinchToZoomListViewController.h"

#import "DNCellButton.h"
#import "DNManagedObject.h"

#import "MHImageCache.h"
#import "NSDate+PrettyDate.h"
#import "NSTimer+Blocks.h"
#import "UIImage+Scale.h"

@interface DNPinchToZoomListViewController ()
{
    BOOL    visibleFlag;
}
@end

@implementation DNPinchToZoomListViewController

- (NSString*)cellNibDefault
{
    return nil;
}

- (NSArray*)cellNibs
{
    return nil;
}

- (NSString*)cellNibKey
{
    return nil;
}

- (NSString*)loadCellNib
{
    cellNib = [DNUtilities settingsItem:[self cellNibKey] default:[self cellNibDefault]];
    if ([[self cellNibs] indexOfObject:cellNib] == NSNotFound)
    {
        cellNib = [self cellNibDefault];
        [self saveCellNib:cellNib];
    }
    
    return cellNib;
}

- (void)saveCellNib:(NSString*)newCellNib
{
    [DNUtilities setSettingsItem:[self cellNibKey] value:newCellNib];
}

- (NSString*)cellNibByIndex:(int)newIndex
{
    if (newIndex < 0)                           {   newIndex = 0;   }
    if (newIndex >= [[self cellNibs] count])    {   newIndex = ([[self cellNibs] count] - 1);   }

    cellNib = [[self cellNibs] objectAtIndex:newIndex];
    NSLog(@"cellNib=%@", cellNib);
    return cellNib;
}

- (id)initWithStyle:(UITableViewStyle)aStyle
{
    self = [super initWithStyle:aStyle];
    if (self)
    {
        [self loadCellNib];
    }
    
    return self;
}

- (UIImage*)imageOfView;
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.listObjects    = [NSMutableArray arrayWithCapacity:10];
    
    // Create location manager with filters set for battery efficiency.
    [[RCLocationManager sharedManager] setUserDistanceFilter:kCLLocationAccuracyBest];
    [[RCLocationManager sharedManager] setUserDesiredAccuracy:kCLLocationAccuracyBest];
    [[RCLocationManager sharedManager] setPurpose:@"Current Location for Capturing/Deploying"];
    [[RCLocationManager sharedManager] addDelegate:self];
    
    listUpdateTime  = [NSDate date];
}

- (void)viewDidUnload
{
    [[RCLocationManager sharedManager] stopUpdatingLocation];
    [[RCLocationManager sharedManager] stopUpdatingHeading];
    [[RCLocationManager sharedManager] stopMonitoringAllRegions];
    
    [[RCLocationManager sharedManager] removeDelegate:self];
    
    [super viewDidUnload];
}

- (BOOL)isSubViewVisible
{
    return visibleFlag;
}

- (void)subViewWillAppear:(BOOL)animated
{
    if ([self.listObjects count] == 0)
    {
        [self firstLoadNewObjects];
    }
}

- (void)subViewDidAppear:(BOOL)animated
{
    visibleFlag = YES;
    
    // Register to receive touch events
    //[DNUtilities setEventInterceptDelegate:self];
    
    /*
     listUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:240.0f
     block:^
     {
     [self loadNewClans];
     }
     repeats:YES];
     */
    
    [[RCLocationManager sharedManager] addDelegate:self];
}

- (void)subViewWillDisappear:(BOOL)animated
{
    // Deregister from receiving touch events
    //[DNUtilities setEventInterceptDelegate:nil];
    
    listUpdateTimer = nil;
}

- (void)subViewDidDisappear:(BOOL)animated
{
    visibleFlag = NO;
    
    [[RCLocationManager sharedManager] removeDelegate:self];
}

- (void)listUpdateAction
{
    [self.tableViewModel reloadBoundValues];
    [self.tableView reloadData];
    
    [self.tableViewModel.pullToRefreshView boundScrollViewDidFinishLoading];
}

- (void)resetCustomCell:(id)mObj
{
    DNManagedObject*   mObject  = mObj;
    mObject.customCell  = nil;
}

- (void)resetCustomCells
{
    [self.listObjects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop)
     {
         DNManagedObject*   mObj    = object;
         [self resetCustomCell:mObj];
     }];
}

#define kMinimumPinchDelta  70 // 150

- (BOOL)interceptEvent:(UIEvent *)event
{
    NSSet*  touches = [event allTouches];
    
    // Give up if user wasn't using two fingers
    if ([touches count] != 2)
    {
        return NO;
    }
    
    UITouchPhase    phase = ((UITouch *)[touches anyObject]).phase;
    CGPoint firstPoint  = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
    CGPoint secondPoint = [[[touches allObjects] objectAtIndex:1] locationInView:self.view];
    
    CGFloat deltaX      = secondPoint.x - firstPoint.x;
    CGFloat deltaY      = secondPoint.y - firstPoint.y;
    CGFloat distance    = sqrt(deltaX*deltaX + deltaY*deltaY);
    
    if (phase == UITouchPhaseBegan)
    {
        initialDistance = distance;
        lastZoomStep    = 0;
        
        initialZoomStep = [[self cellNibs] indexOfObject:cellNib];
    }
    else if (phase == UITouchPhaseMoved)
    {
        CGFloat currentDistance = distance;
        
        if (initialDistance == 0)
        {
            initialDistance = currentDistance;
            lastZoomStep    = 0;
            
            initialZoomStep = [[self cellNibs] indexOfObject:cellNib];
        }
        else if (currentDistance - initialDistance > kMinimumPinchDelta)
        {
            CGFloat     delta   = currentDistance - initialDistance;
            NSInteger   step    = (delta + (kMinimumPinchDelta / 2)) / kMinimumPinchDelta;
            
            if (step != lastZoomStep)
            {
                [self saveCellNib:[self cellNibByIndex:(initialZoomStep + step)]];
                
                [self resetCustomCells];
                [self listUpdateAction];
                
                lastZoomStep    = step;
            }
        }
        else if ((initialDistance - currentDistance) > kMinimumPinchDelta)
        {
            CGFloat     delta   = initialDistance - currentDistance;
            NSInteger   step    = (delta + (kMinimumPinchDelta / 2)) / kMinimumPinchDelta;
            
            if (step != lastZoomStep)
            {
                [self saveCellNib:[self cellNibByIndex:(initialZoomStep - step)]];

                [self resetCustomCells];
                [self listUpdateAction];
                
                lastZoomStep    = step;
            }
        }
    }
    else if (phase == UITouchPhaseEnded)
    {
        [self listUpdateAction];
        initialDistance = 0;
    }
    
    return NO;
}

- (void)firstLoadNewObjects
{
    [self loadNewObjects];
}

- (void)loadNewObjects
{
    listUpdateTime  = [NSDate date];
    [self listUpdateAction];
}

#pragma mark - RCLocationManagerDelegate

- (void)locationManager:(RCLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    //DLog(LL_Debug, @"newHeading=%.2f", newHeading.trueHeading);
}

- (void)locationManager:(RCLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //DLog(LL_Debug, @"newLocation=(%.2f, %.2f)", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

@end
