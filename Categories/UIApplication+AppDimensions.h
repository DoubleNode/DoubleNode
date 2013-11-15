//
//  UIApplication+AppDimensions.h
//  Phoenix
//
//  Created by Darren Ehlers on 11/15/13.
//  Copyright (c) 2013 Table Project. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (AppDimensions)

+ (UIInterfaceOrientation)currentOrientation;

+ (CGSize)currentSize;
+ (CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation;

@end
