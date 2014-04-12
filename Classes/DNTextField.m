//
//  DNTextField.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNTextField.h"

@implementation DNTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + self.horizontalPadding, bounds.origin.y + self.verticalPadding, bounds.size.width - self.horizontalPadding * 2, bounds.size.height - self.verticalPadding * 2);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

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

@end
