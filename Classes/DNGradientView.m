//
//  DNGradientView.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNGradientView.h"

@implementation DNGradientView

@dynamic layer;

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

@end
