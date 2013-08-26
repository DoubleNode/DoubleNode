//
//  DNAdUIViewController.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNUtilities.h"

#import "DNAdUIViewController.h"

@interface DNAdUIViewController ()

@end

@implementation DNAdUIViewController

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
    // AD Configuration
    if ([DNUtilities isDeviceIPad])
    {
        self.GADBannerViewPublisherID   = [DNAppConstants adAdModIpadPublisherID];
    }
    else
    {
        self.GADBannerViewPublisherID   = [DNAppConstants adAdModIphonePublisherID];
    }

    if ([[DNAppConstants adLocation] isEqualToString:@"bottom"])
    {
        self.adLocation     = JTCAdBaseViewAdLocationBottom;
    }
    else
    {
        self.adLocation     = JTCAdBaseViewAdLocationTop;
    }
    
    // if user purchase ad, you simply put self.isAdRemoved = YES; and Ads doesn't show.
    self.isAdRemoved    = ![DNAppConstants adEnabled];
    
    // if you prefer admob first, put JTCAdBaseViewAdPriorityAdMob
    if ([DNAppConstants adAdMobPriority])
    {
        self.adPriority = JTCAdBaseViewAdPriorityAdMob;
    }
    else
    {
        self.adPriority = JTCAdBaseViewAdPriority_iAd;
    }
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
