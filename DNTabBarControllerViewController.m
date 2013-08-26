//
//  DNTabBarControllerViewController.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/16/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNTabBarControllerViewController.h"

@interface DNTabBarControllerViewController ()

@property (strong, nonatomic) UIImageView*   tabBarArrow;

@end

@implementation DNTabBarControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    self.tabBarArrow    = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.tabBarArrow)
    {
        [self addTabBarArrow];
    }
    [self tabBar:self.tabBar didSelectItem:self.tabBar.selectedItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Screen Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    self.tabBarArrow.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self tabBar:self.tabBar didSelectItem:self.tabBar.selectedItem];
}

#pragma mark - TabBarArrow

+ (CGRect)frameForTabInTabBar:(UITabBar*)tabBar withIndex:(NSUInteger)index
{
    NSUInteger currentTabIndex = 0;
    
    for (UIView* subView in tabBar.subviews)
    {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")])
        {
            if (currentTabIndex == index)
            {
                return subView.frame;
            }
            else
            {
                currentTabIndex++;
            }
        }
    }
    
    NSAssert(NO, @"Index is out of bounds");
    return CGRectMake(0, 0, 0, 0);
}

- (CGFloat)tbnNippleHorizontalLocationFor:(NSUInteger)tabIndex
{
    CGRect  tbiFrame        = [DNTabBarControllerViewController frameForTabInTabBar:self.tabBar withIndex:tabIndex];
    CGFloat tabItemWidth    = tbiFrame.size.width;
    CGFloat tbiHalfWidth    = (tabItemWidth / 2.0) - (self.tabBarArrow.frame.size.width / 2.0);
    
    return tbiFrame.origin.x + tbiHalfWidth;
}

- (CGFloat)tbnNippleVerticalLocation
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        return self.view.frame.size.width - self.tabBar.frame.size.height - self.tabBarArrow.image.size.height + 2;
    }
    
    return self.view.frame.size.height - self.tabBar.frame.size.height - self.tabBarArrow.image.size.height + 2;
}

- (void)addTabBarArrow
{
    UIImage* tabBarArrowImage = [UIImage imageNamed:@"TabBarNipple.png"];
    self.tabBarArrow = [[UIImageView alloc] initWithImage:tabBarArrowImage];
    
    self.tabBarArrow.frame = CGRectMake([self tbnNippleHorizontalLocationFor:1], [self tbnNippleVerticalLocation], tabBarArrowImage.size.width, tabBarArrowImage.size.height);
    
    [self.view addSubview:self.tabBarArrow];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar*)tabBar didSelectItem:(UITabBarItem*)item
{
    CGRect frame = self.tabBarArrow.frame;
    frame.origin.x = [self tbnNippleHorizontalLocationFor:item.tag];
    frame.origin.y = [self tbnNippleVerticalLocation];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationCurveLinear
                     animations:^
     {
         self.tabBarArrow.frame = frame;
     }
                     completion:^(BOOL finished)
     {
         self.tabBarArrow.hidden = NO;
     }];
}

@end
