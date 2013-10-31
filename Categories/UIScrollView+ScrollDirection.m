//
//  UIScrollView+ScrollDirection.m
//  Phoenix
//
//  Created by Darren Ehlers on 10/29/13.
//  Copyright (c) 2013 Table Project. All rights reserved.
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
