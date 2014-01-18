//
//  UIView+ImageOfView.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "UIView+ImageOfView.h"

@implementation UIView (ImageOfView)

- (UIImage*)imageOfView;
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage*    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

@end
