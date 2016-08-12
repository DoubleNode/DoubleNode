//
//  UIView+DropShadow.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DropShadow)

- (void)addDropShadow;

- (void)addDropShadow:(UIColor*)color;

- (void)addDropShadow:(UIColor*)color
           withOffset:(CGSize)offset
               radius:(CGFloat)radius
              opacity:(CGFloat)opacity;

@end
