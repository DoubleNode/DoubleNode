//
//  DNTextView.m
//  Pods
//
//  Created by Darren Ehlers on 11/8/13.
//
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

@end
