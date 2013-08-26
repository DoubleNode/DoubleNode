//
//  DNPinchToZoomListViewController.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNUIViewController.h"
#import "DNCellButton.h"

#import "RCLocationManager.h"

@interface DNPinchToZoomListViewController : SCTableViewController<DNEventInterceptWindowDelegate, RCLocationManagerDelegate>
{
    NSString*   cellNibDefaultValue;
    NSString*   cellNibKeyValue;
    NSArray*    cellNibArray;
    NSString*   cellNib;
    
    NSTimer*    listUpdateTimer;
    NSDate*     listUpdateTime;
    
    CGFloat     initialDistance;
    NSInteger   initialZoomStep;
    NSInteger   lastZoomStep;
    
    DNCellButton*   lastCellButton;
}

@property (weak, nonatomic) IBOutlet UIViewController*  owner;

@property (strong, nonatomic) NSMutableArray*           listObjects;
@property (strong, nonatomic) SCArrayOfStringsSection*  listSection;

- (NSString*)cellNibDefault;
- (NSArray*)cellNibs;
- (NSString*)cellNibKey;
- (NSString*)loadCellNib;
- (void)saveCellNib:(NSString*)newCellNib;
- (NSString*)cellNibByIndex:(int)newIndex;

- (id)initWithStyle:(UITableViewStyle)aStyle;
- (UIImage*)imageOfView;

- (void)viewDidLoad;
- (void)viewDidUnload;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)subViewWillAppear:(BOOL)animated;
- (void)subViewDidAppear:(BOOL)animated;
- (void)subViewWillDisappear:(BOOL)animated;
- (void)subViewDidDisappear:(BOOL)animated;

- (void)listUpdateAction;
- (BOOL)interceptEvent:(UIEvent *)event;

- (void)firstLoadNewObjects;
- (void)loadNewObjects;
- (void)locationManager:(RCLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading;
- (void)locationManager:(RCLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

@end

