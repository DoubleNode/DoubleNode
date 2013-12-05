//
//  UIView+Pending.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#include <objc/runtime.h>

#import "UIView+Pending.h"

const NSString* kPendingAlpha   = @"PendingAlpha";
const NSString* kPendingFrame   = @"PendingFrame";

@implementation UIView (Pending)

- (void)setPendingAlpha:(float)pendingAlpha
{
    objc_setAssociatedObject(self, &kPendingAlpha, [NSNumber numberWithFloat:pendingAlpha], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)pendingAlpha
{
    return [objc_getAssociatedObject(self, &kPendingAlpha) floatValue];
}

- (void)setPendingFrame:(CGRect)pendingFrame
{
    objc_setAssociatedObject(self, &kPendingFrame, [NSValue valueWithCGRect:pendingFrame], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)pendingFrame
{
    return [objc_getAssociatedObject(self, &kPendingFrame) CGRectValue];
}

- (void)resetPendingValues
{
    self.pendingAlpha   = self.alpha;
    self.pendingFrame   = self.frame;
}

- (void)applyPendingValues
{
    self.alpha  = self.pendingAlpha;
    self.frame  = self.pendingFrame;
}

@end
