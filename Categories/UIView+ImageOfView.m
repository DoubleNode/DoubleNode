//
//  UIView+ImageOfView.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "UIView+ImageOfView.h"

@implementation UIView (ImageOfView)

- (UIImage*)imageOfView
{
    // DME: Old code replaced with faster iOS7 method
    //UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    //[self.layer renderInContext:UIGraphicsGetCurrentContext()];

    // Create the image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);

    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];

    UIImage*    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

- (UIImage*)imageOfViewInFrame:(CGRect)frame
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, self.window.screen.scale);

    [self drawViewHierarchyInRect:frame afterScreenUpdates:NO];

    UIImage*    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

@end
