//
//  UIImage+White2Transparent.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "UIImage+White2Transparent.h"

@implementation UIImage (White2Transparent)

- (UIImage*)whiteColorToTransparent
{
    CGImageRef rawImageRef = self.CGImage;
    
    const CGFloat   colorMaskingSource[6]   = {222, 255, 222, 255, 222, 255};
    const CGFloat*  colorMasking            = colorMaskingSource;
    
    UIGraphicsBeginImageContext(self.size);
    
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iPhone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, self.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height), maskedImageRef);
    
    UIImage*    result = UIGraphicsGetImageFromCurrentImageContext();
    
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    
    return result;
}

@end
