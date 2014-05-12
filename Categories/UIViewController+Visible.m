//
//  UIViewController+Visible.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "UIViewController+Visible.h"

@implementation UIViewController (Visible)

- (BOOL)isVisible
{
    if (self.isViewLoaded && self.view.window)
    {
        return YES;
    }

    return NO;
}

@end
