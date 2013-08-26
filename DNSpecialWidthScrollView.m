//
//  DNSpecialWidthScrollView.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/29/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNSpecialWidthScrollView.h"

@implementation DNSpecialWidthScrollView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint parentLocation = [self convertPoint:point toView:self.superview];
    
    CGRect  responseRect = self.frame;
    responseRect.origin.x       -= self.responseInsets.left;
    responseRect.origin.y       -= self.responseInsets.top;
    responseRect.size.width     += (self.responseInsets.left + self.responseInsets.right);
    responseRect.size.height    += (self.responseInsets.top + self.responseInsets.bottom);
    return CGRectContainsPoint(responseRect, parentLocation);
}

@end

