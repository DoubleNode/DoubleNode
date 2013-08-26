//
//  DNUITableViewController.m
//  MZ Proto
//
//  Created by Darren Ehlers on 8/11/13.
//  Copyright (c) 2013 DoubleNode.com. All rights reserved.
//

#import "DNUITableViewController.h"

@interface DNUITableViewController ()
{
    BOOL    visibleFlag;
}
@end

@implementation DNUITableViewController

- (BOOL)isSubViewVisible
{
    return visibleFlag;
}

- (void)subViewWillAppear:(BOOL)animated
{
    
}

- (void)subViewDidAppear:(BOOL)animated
{
    visibleFlag = YES;
}

- (void)subViewWillDisappear:(BOOL)animated
{
    
}

- (void)subViewDidDisappear:(BOOL)animated
{
    visibleFlag = NO;
}

- (UIImage*)imageOfView;
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
