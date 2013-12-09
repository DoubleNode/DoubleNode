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

- (CGPoint)origin   {   return self.frame.origin;       }
- (CGFloat)x        {   return self.frame.origin.x;     }
- (CGFloat)y        {   return self.frame.origin.y;     }
- (CGSize)size      {   return self.frame.size;         }
- (CGFloat)width    {   return self.frame.size.width;   }
- (CGFloat)height   {   return self.frame.size.height;  }

- (void)setOrigin:(CGPoint)origin
{
    self.frame   = (CGRect){ origin.x, origin.y, self.frame.size };
}

- (void)setX:(CGFloat)x
{
    self.frame   = (CGRect){ x, self.frame.origin.y, self.frame.size };
}

- (void)setY:(CGFloat)y
{
    self.frame   = (CGRect){ self.frame.origin.x, y, self.frame.size };
}

- (void)setSize:(CGSize)size
{
    self.frame   = (CGRect){ self.frame.origin, size.width, size.height };
}

- (void)setWidth:(CGFloat)width
{
    self.frame   = (CGRect){ self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height };
}

- (void)setHeight:(CGFloat)height
{
    self.frame   = (CGRect){ self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height };
}

- (CGPoint)pendingOrigin    {   return self.pendingFrame.origin;        }
- (CGFloat)pendingX         {   return self.pendingFrame.origin.x;      }
- (CGFloat)pendingY         {   return self.pendingFrame.origin.y;      }
- (CGSize)pendingSize       {   return self.pendingFrame.size;          }
- (CGFloat)pendingWidth     {   return self.pendingFrame.size.width;    }
- (CGFloat)pendingHeight    {   return self.pendingFrame.size.height;   }

- (void)setPendingOrigin:(CGPoint)pendingOrigin
{
    self.pendingFrame   = (CGRect){ pendingOrigin.x, pendingOrigin.y, self.pendingFrame.size };
}

- (void)setPendingX:(CGFloat)pendingX
{
    self.pendingFrame   = (CGRect){ pendingX, self.pendingFrame.origin.y, self.pendingFrame.size };
}

- (void)setPendingY:(CGFloat)pendingY
{
    self.pendingFrame   = (CGRect){ self.pendingFrame.origin.x, pendingY, self.pendingFrame.size };
}

- (void)setPendingSize:(CGSize)pendingSize
{
    self.pendingFrame   = (CGRect){ self.pendingFrame.origin, pendingSize.width, pendingSize.height };
}

- (void)setPendingWidth:(CGFloat)pendingWidth
{
    self.pendingFrame   = (CGRect){ self.pendingFrame.origin.x, self.pendingFrame.origin.y, pendingWidth, self.pendingFrame.size.height };
}

- (void)setPendingHeight:(CGFloat)pendingHeight
{
    self.pendingFrame   = (CGRect){ self.pendingFrame.origin.x, self.pendingFrame.origin.y, self.pendingFrame.size.width, pendingHeight };
}

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

- (void)resetPendingAlpha
{
    self.pendingAlpha   = self.alpha;
}

- (void)resetPendingFrame
{
    self.pendingFrame   = self.frame;
}

- (void)resetPendingValues
{
    [self resetPendingAlpha];
    [self resetPendingFrame];
}

- (void)applyPendingAlpha
{
    self.alpha  = self.pendingAlpha;
}

- (void)applyPendingFrame
{
    self.frame  = self.pendingFrame;
}

- (void)applyPendingValues
{
    [self applyPendingAlpha];
    [self applyPendingFrame];
}

@end
