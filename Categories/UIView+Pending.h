//
//  UIView+Pending.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Pending)

@property (atomic, assign) float            pendingAlpha;
@property (atomic, assign) CGRect           pendingFrame;
@property (atomic, assign) CATransform3D    pendingTransform;

@property (atomic, assign) CGPoint  origin;
@property (atomic, assign) CGFloat  x;
@property (atomic, assign) CGFloat  y;
@property (atomic, assign) CGSize   size;
@property (atomic, assign) CGFloat  width;
@property (atomic, assign) CGFloat  height;

@property (atomic, assign) CGPoint  pendingOrigin;
@property (atomic, assign) CGFloat  pendingX;
@property (atomic, assign) CGFloat  pendingY;
@property (atomic, assign) CGSize   pendingSize;
@property (atomic, assign) CGFloat  pendingWidth;
@property (atomic, assign) CGFloat  pendingHeight;

/**
 *  Returns if the view is currently loaded and visible.
 */
- (BOOL)isVisible;

/**
 *  Resets pending alpha value to current alpha value.
 */
- (void)resetPendingAlpha;

/**
 *  Resets pending frame value to current frame value.
 */
- (void)resetPendingFrame;

/**
 *  Resets pending transform value to current transform value.
 */
- (void)resetPendingTransform;

/**
 *  Resets pending values to current values.
 */
- (void)resetPendingValues;

/**
 *  Sets current alpha value to pending alpha value.
 */
- (void)applyPendingAlpha;

/**
 *  Sets current frame value to pending frame value.
 */
- (void)applyPendingFrame;

/**
 *  Sets current transform value to pending transform value.
 */
- (void)applyPendingTransform;

/**
 *  Sets current values to pending values.
 */
- (void)applyPendingValues;

@end
