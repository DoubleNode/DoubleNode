//
//  UIScrollView+ScrollDirection.h
//  Phoenix
//
//  Created by Darren Ehlers on 10/29/13.
//  Copyright (c) 2013 Table Project. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Defines ScrollDirection bitmask flags
 */
typedef NS_OPTIONS(NSInteger, ScrollDirection)
{
    /**
     *  The UIScrollView is not scrolling
     */
    ScrollDirectionNone     = 0,
    /**
     *  The UIScrollView is scrolling to the right
     */
    ScrollDirectionRight    = 1 << 0,
    /**
     *  The UIScrollView is scrolling to the left
     */
    ScrollDirectionLeft     = 1 << 1,
    /**
     *  The UIScrollView is scrolling up
     */
    ScrollDirectionUp       = 1 << 2,
    /**
     *  The UIScrollView is scrolling down
     */
    ScrollDirectionDown     = 1 << 3
};

@interface UIScrollView (ScrollDirection)

/**
 *  Returns the current scroll direction(s)
 *
 *  @param lastContentOffset The last contentOffset point
 *
 *  @return ScrollDirection value of multiple direction flags or'd together.
 */
- (ScrollDirection)scrollDirection:(CGPoint)lastContentOffset;

@end
