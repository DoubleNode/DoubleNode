//
//  UIScrollView+ScrollDirection.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "UIScrollView+ScrollDirection.h"

@implementation UIScrollView (ScrollDirection)

- (ScrollDirection)scrollDirection:(CGPoint)lastContentOffset
{
    ScrollDirection retval = ScrollDirectionNone;

    if (lastContentOffset.x > self.contentOffset.x)
    {
        retval |= ScrollDirectionRight;
    }
    else if (lastContentOffset.x < self.contentOffset.x)
    {
        retval |= ScrollDirectionLeft;
    }

    if (lastContentOffset.y > self.contentOffset.y)
    {
        retval |= ScrollDirectionDown;
    }
    else if (lastContentOffset.y < self.contentOffset.y)
    {
        retval |= ScrollDirectionUp;
    }

    return retval;
}

@end
