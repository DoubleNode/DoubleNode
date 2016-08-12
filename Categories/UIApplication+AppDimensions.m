//
//  UIApplication+AppDimensions.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "UIApplication+AppDimensions.h"

@implementation UIApplication (AppDimensions)

+ (UIInterfaceOrientation)currentOrientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}

+ (CGSize)currentSize
{
    return [UIApplication sizeInOrientation:[UIApplication currentOrientation]];
}

+ (CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize          size        = [UIScreen mainScreen].bounds.size;
    UIApplication*  application = [UIApplication sharedApplication];

    if (UIDeviceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }

    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }

    return size;
}

@end
