//
//  DNStateViewController.m
//  Phoenix
//
//  Created by Darren Ehlers on 11/9/13.
//  Copyright (c) 2013 Table Project. All rights reserved.
//

#import "DNStateViewController.h"

@interface DNStateViewController ()

@end

@implementation DNStateViewController

- (void)changeToViewState:(NSString*)newViewState
                 animated:(BOOL)animated
               completion:(void(^)(BOOL finished))completion
{
    if ([newViewState isEqualToString:currentViewState] == YES)
    {
        return;
    }

    [self changeFromCurrentState:currentViewState
                      toNewState:newViewState
                        animated:animated
                      completion:^(BOOL finished)
     {
         currentViewState = newViewState;
         if (completion != nil) {   completion(finished);   }
     }];
}

- (void)changeFromCurrentState:(NSString*)currentState
                    toNewState:(NSString*)newState
                      animated:(BOOL)animated
                    completion:(void(^)(BOOL finished))completion
{
    DNStateOptions* options = [DNStateOptions stateOptions];
    options.animated    = animated;
    options.completion  = completion;

    if (currentState != nil)
    {
        NSString*   functionName    = [NSString stringWithFormat:@"changeFromViewState%@To%@:", currentState, newState];
        if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
        {
            [self performViewStateSelector:NSSelectorFromString(functionName) options:options];
            return;
        }
    }

    NSString*   functionName    = [NSString stringWithFormat:@"changeToViewState%@:", newState];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        [self performViewStateSelector:NSSelectorFromString(functionName) options:options];
        return;
    }

    return;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)performViewStateSelector:(SEL)aSelector
                         options:(DNStateOptions*)options
{
    if (aSelector == nil)   {   return; }

    [self performSelector:aSelector withObject:options];
}

#pragma clang diagnostic pop

@end
