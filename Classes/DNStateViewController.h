//
//  DNStateViewController.h
//  Phoenix
//
//  Created by Darren Ehlers on 11/9/13.
//  Copyright (c) 2013 Table Project. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DNStateOptions.h"

@interface DNStateViewController : UIViewController
{
    NSString*   currentViewState;
}

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
