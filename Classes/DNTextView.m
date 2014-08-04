//
//  DNTextView.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNTextView.h"

@implementation DNTextView

- (void)shake
{
    static int numberOfShakes = 4;

    CALayer*    layer   = [self layer];
    CGPoint     pos     = layer.position;

    CAKeyframeAnimation*    shakeAnimation  = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef        shakePath       = CGPathCreateMutable();

    CGPathMoveToPoint(shakePath, NULL, pos.x, pos.y);

    for (int index = 0; index < numberOfShakes; ++index)
    {
        CGPathAddLineToPoint(shakePath, NULL, pos.x - 8, pos.y);
        CGPathAddLineToPoint(shakePath, NULL, pos.x + 8, pos.y);
    }

    CGPathAddLineToPoint(shakePath, NULL, pos.x, pos.y);
    CGPathCloseSubpath(shakePath);

    shakeAnimation.timingFunction   = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    shakeAnimation.duration         = 1.2;
    shakeAnimation.path             = shakePath;

    [layer addAnimation:shakeAnimation forKey:nil];
}

// DME: Touches intercepted and forwarded to nextResponder and super to handle touched embedded links and data detector results
- (void)touchesBegan:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    [self.nextResponder touchesBegan:touches withEvent:event];

    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    [self.nextResponder touchesMoved:touches withEvent:event];

    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    [self.nextResponder touchesEnded:touches withEvent:event];

    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet*)touches
               withEvent:(UIEvent*)event
{
    [self.nextResponder touchesCancelled:touches withEvent:event];

    [super touchesCancelled:touches withEvent:event];
}

@end
