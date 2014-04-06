//
//  UIApplication+AppDimensions.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (AppDimensions)

+ (UIInterfaceOrientation)currentOrientation;

+ (CGSize)currentSize;
+ (CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation;

@end
