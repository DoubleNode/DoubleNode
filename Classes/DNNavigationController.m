//
//  DNNavigationController.m
//  Phoenix
//
//  Created by Darren Ehlers on 10/27/13.
//  Copyright (c) 2013 Table Project. All rights reserved.
//

#import "DNNavigationController.h"

@interface DNNavigationController ()

@end

@implementation DNNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.topViewController.preferredStatusBarStyle;
}

@end
