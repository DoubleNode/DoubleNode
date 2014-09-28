//
//  DNButton.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.

#import "DNButton.h"

@interface DNButton ()
{
    NSMutableDictionary*    tintColorStates;
}

@end

@implementation DNButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Initialization code
    }

    return self;
}

- (void)setTintColor:(UIColor*)tintColor
            forState:(UIControlState)state
{
    if (tintColorStates == nil)
    {
        tintColorStates = [[NSMutableDictionary alloc] init];
    }

    [tintColorStates setObject:tintColor forKey:[NSNumber numberWithInt:state]];

    if (self.tintColor == nil)
    {
        [self setTintColor:tintColor];
        [self setNeedsDisplay];
    }
}

- (UIColor*)tintColorForState:(UIControlState)state
{
    return [tintColorStates objectForKey:[NSNumber numberWithInt:state]];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    [super touchesBegan:touches withEvent:event];

    UIColor*    highlightedColor = tintColorStates[@(UIControlStateHighlighted)];
    if (highlightedColor)
    {
        self.tintColor = highlightedColor;
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet*)touches
               withEvent:(UIEvent*)event
{
    [super touchesCancelled:touches withEvent:event];

    UIColor*    normalColor = tintColorStates[@(UIControlStateNormal)];
    if (normalColor)
    {
        self.tintColor = normalColor;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    [super touchesEnded:touches withEvent:event];

    UIColor*    normalColor = tintColorStates[@(UIControlStateNormal)];
    if (normalColor)
    {
        self.tintColor = normalColor;
        [self setNeedsDisplay];
    }
}

@end
