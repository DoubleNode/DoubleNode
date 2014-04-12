//
//  DNStateViewController.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DNStateOptions.h"

#import "UIView+Pending.h"

@interface DNStateViewController : UIViewController
{
    NSString*   previousViewState;
}

@property (weak, nonatomic) NSString*   currentViewState;

@property (atomic) BOOL     transitionPending;

- (void)viewStateWillAppear:(NSString*)newViewState
                   animated:(BOOL)animated;

- (void)viewStateDidAppear:(NSString*)newViewState
                  animated:(BOOL)animated;

- (void)changeToViewState:(NSString*)newViewState
                 animated:(BOOL)animated
               completion:(void(^)(BOOL finished))completion;

- (void)changeFromCurrentState:(NSString*)currentState
                    toNewState:(NSString*)newState
                      animated:(BOOL)animated
                    completion:(void(^)(BOOL finished))completion;

- (void)performViewStateSelector:(SEL)aSelector
                         options:(DNStateOptions*)options;

@end
