//
//  UIView+Pending.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Pending)

@property (atomic, assign) float     pendingAlpha;
@property (atomic, assign) CGRect    pendingFrame;

/**
 *  Resets pending values to current values.
 */
- (void)resetPendingValues;

/**
 *  Sets current values to pending values.
 */
- (void)applyPendingValues;

@end
