//
//  UIView+DropShadow.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "UIView+DropShadow.h"

@implementation UIView (DropShadow)

const CGSize    DS_DEFAULT_OFFSET   = (CGSize){ 3, 3 };
const CGFloat   DS_DEFAULT_RADIUS   = 2.0f;
const CGFloat   DS_DEFAULT_OPACITY  = 0.6f;

- (void)addDropShadow
{
    [self addDropShadow:[UIColor blackColor]
             withOffset:DS_DEFAULT_OFFSET
                 radius:DS_DEFAULT_RADIUS
                opacity:DS_DEFAULT_OPACITY];
}

- (void)addDropShadow:(UIColor*)color
{
    [self addDropShadow:color
             withOffset:DS_DEFAULT_OFFSET
                 radius:DS_DEFAULT_RADIUS
                opacity:DS_DEFAULT_OPACITY];
}

- (void)addDropShadow:(UIColor*)color
           withOffset:(CGSize)offset
               radius:(CGFloat)radius
              opacity:(CGFloat)opacity
{
    self.layer.shadowColor      = color.CGColor;
    self.layer.shadowOffset     = offset;
    self.layer.shadowRadius     = radius;
    self.layer.shadowOpacity    = (float)opacity;
}

@end
