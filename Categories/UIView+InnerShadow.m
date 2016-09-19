//
//  UIView+InnerShadow.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <YIInnerShadowView/YIInnerShadowView.h>

#import "UIView+InnerShadow.h"

@implementation UIView (InnerShadow)

const CGSize    DS_DEFAULT_OFFSET   = (CGSize){ 3, 3 };
const CGFloat   DS_DEFAULT_RADIUS   = 2.0f;
const CGFloat   DS_DEFAULT_OPACITY  = 0.6f;

- (void)addInnerShadow
{
    [self addInnerShadow:[UIColor blackColor]
             withOffset:DS_DEFAULT_OFFSET
                 radius:DS_DEFAULT_RADIUS
                opacity:DS_DEFAULT_OPACITY];
}

- (void)addInnerShadow:(UIColor*)color
{
    [self addInnerShadow:color
             withOffset:DS_DEFAULT_OFFSET
                 radius:DS_DEFAULT_RADIUS
                opacity:DS_DEFAULT_OPACITY];
}

- (void)addInnerShadow:(UIColor*)color
            withOffset:(CGSize)offset
                radius:(CGFloat)radius
               opacity:(CGFloat)opacity
{
    YIInnerShadowView* innerShadowView = [[YIInnerShadowView alloc] initWithFrame:self.frame];
    innerShadowView.shadowColor     = color;
    innerShadowView.shadowOffset    = offset;
    innerShadowView.shadowRadius    = radius;
    innerShadowView.shadowOpacity   = opacity;
    innerShadowView.shadowMask      = YIInnerShadowMaskBottom;
    [self addSubview:innerShadowView];
}

@end
