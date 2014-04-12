//
//  DNStateViewController.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNStateViewController.h"

#import "DNUtilities.h"

#import "NSObject+PropertiesDictionary.h"

@interface DNStateViewController ()

@end

@implementation DNStateViewController

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [self transitionToViewState:_currentViewState animated:YES completion:nil];
}

- (void)viewStateWillAppear:(NSString*)newViewState
                   animated:(BOOL)animated
{
}

- (void)viewStateDidAppear:(NSString*)newViewState
                  animated:(BOOL)animated
{
}

- (void)callSetupPendingPropertiesForViewState:(NSString*)newViewState
{
    BOOL    anyRun = NO;

    NSString*   functionName    = [NSString stringWithFormat:@"setupPendingPropertiesForAllViewStates"];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_ViewState, @"Calling %@...", functionName);
        [self performViewStateSelector:NSSelectorFromString(functionName) options:nil];
        anyRun = YES;
    }

    functionName    = [NSString stringWithFormat:@"setupPendingPropertiesForViewState%@", newViewState];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_ViewState, @"Calling %@...", functionName);
        [self performViewStateSelector:NSSelectorFromString(functionName) options:nil];
        anyRun = YES;
    }

    if (!anyRun)
    {
        DLog(LL_Debug, LD_ViewState, @"No setupPendingProperties function called! (newViewState=%@)", newViewState);
    }
}

- (void)changeToViewState:(NSString*)newViewState
                 animated:(BOOL)animated
               completion:(void(^)(BOOL finished))completion
{
    if ([newViewState isEqualToString:_currentViewState] == YES)
    {
        return;
    }

    DLog(LL_Debug, LD_ViewState, @"Transition from %@ to %@...", _currentViewState, newViewState);

    [self transitionToViewState:newViewState animated:animated completion:completion];
}

- (void)transitionToViewState:(NSString*)newViewState
                     animated:(BOOL)animated
                   completion:(void(^)(BOOL finished))completion
{
    self.transitionPending  = YES;

    [DNUtilities runOnMainThreadWithoutDeadlocking:^
     {
         [[self propertiesDictionary] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
          {
              if ([obj isKindOfClass:[UIView class]] == YES)
              {
                  [obj resetPendingValues];
              }
          }];
         
         [self viewStateWillAppear:newViewState animated:animated];

         NSString*  currentState = _currentViewState;
         if ([currentState isEqualToString:newViewState] == YES)
         {
             currentState = previousViewState;
         }

         [self callSetupPendingPropertiesForViewState:newViewState];

         [self changeFromCurrentState:currentState
                           toNewState:newViewState
                             animated:animated
                           completion:^(BOOL finished)
          {
              previousViewState = currentState;
              _currentViewState = newViewState;

              self.transitionPending  = NO;

              [DNUtilities runOnMainThreadWithoutDeadlocking:^
               {
                   [self viewStateDidAppear:newViewState animated:animated];
                   if (completion != nil) {   completion(finished);   }

                   [UIView animateWithDuration:0.5f animations:^
                    {
                        [[self propertiesDictionary] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                         {
                             if ([obj isKindOfClass:[UIView class]] == YES)
                             {
                                 [obj applyPendingValues];
                             }
                         }];
                    }];
               }];
          }];
     }];
}

- (double)transitionDurationFromCurrentState:(NSString*)currentState
                                  toNewState:(NSString*)newState
{
    if (currentState != nil)
    {
        NSString*   functionName    = [NSString stringWithFormat:@"transitionDurationFromViewState%@To%@", currentState, newState];
        if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
        {
            DLog(LL_Debug, LD_ViewState, @"Calling %@...", functionName);
            return [self performDurationViewStateSelector:NSSelectorFromString(functionName)];
        }
    }

    return 1.0f;
}

- (double)transitionDurationFromCurrentState:(NSString*)currentState
{
    NSString*   functionName    = [NSString stringWithFormat:@"transitionDurationFromViewState%@", currentState];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_ViewState, @"Calling %@...", functionName);
        return [self performDurationViewStateSelector:NSSelectorFromString(functionName)];
    }

    return 0.5f;
}

- (double)transitionDurationToNewState:(NSString*)newState
{
    NSString*   functionName    = [NSString stringWithFormat:@"transitionDurationToViewState%@", newState];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_ViewState, @"Calling %@...", functionName);
        return [self performDurationViewStateSelector:NSSelectorFromString(functionName)];
    }

    return 0.5f;
}

- (void)changeFromCurrentState:(NSString*)currentState
                    toNewState:(NSString*)newState
                      animated:(BOOL)animated
                    completion:(void(^)(BOOL finished))completion
{
    DNStateOptions* options = [DNStateOptions stateOptions];
    options.animated        = animated;
    options.completion      = completion;
    options.duration        = [self transitionDurationFromCurrentState:currentState toNewState:newState];
    options.fromDuration    = [self transitionDurationFromCurrentState:currentState];
    options.toDuration      = [self transitionDurationToNewState:newState];

    if (currentState != nil)
    {
        NSString*   functionName    = [NSString stringWithFormat:@"transitionFromViewState%@To%@:", currentState, newState];
        if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
        {
            [UIView animateKeyframesWithDuration:((options.animated == YES) ? options.duration : 0.0f)
                                           delay:0.0f
                                         options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                      animations:^
             {
                 DLog(LL_Debug, LD_ViewState, @"Calling %@...", functionName);
                 [self performViewStateSelector:NSSelectorFromString(functionName) options:options];
             }
                                      completion:options.completion];
            return;
        }
    }

    SEL     fromSelector    = nil;
    SEL     toSelector      = nil;
    BOOL    anyRun          = NO;

    NSString*   functionName    = [NSString stringWithFormat:@"transitionFromViewState%@:", currentState];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_ViewState, @"Calling %@...", functionName);
        fromSelector    = NSSelectorFromString(functionName);
        anyRun          = YES;
    }

    functionName    = [NSString stringWithFormat:@"transitionToViewState%@:", newState];
    if ([self respondsToSelector:NSSelectorFromString(functionName)] == YES)
    {
        DLog(LL_Debug, LD_ViewState, @"Calling %@...", functionName);
        toSelector      = NSSelectorFromString(functionName);
        anyRun          = YES;
    }

    if (anyRun)
    {
        if (fromSelector)
        {
            [UIView animateKeyframesWithDuration:((options.animated == YES) ? options.fromDuration : 0.0f)
                                           delay:0.0f
                                         options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                      animations:^
             {
                 [self performViewStateSelector:fromSelector options:options];
             }
                                      completion:(toSelector ? nil : options.completion)];
        }

        if (toSelector)
        {
            [UIView animateKeyframesWithDuration:((options.animated == YES) ? options.toDuration : 0.0f)
                                           delay:(fromSelector ? options.fromDuration : 0.0f)
                                         options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                      animations:^
             {
                 [self performViewStateSelector:toSelector options:options];
             }
                                      completion:options.completion];
        }
    }
    else
    {
        DLog(LL_Debug, LD_ViewState, @"No transitionViewState function called! (currentState=%@, newState=%@)", currentState, newState);
        if (completion)
        {
            completion(YES);
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (double)performDurationViewStateSelector:(SEL)aSelector
{
    if (aSelector == nil)   {   return 1.0f;    }

    NSInvocation*   invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:aSelector]];
    [invocation setSelector:aSelector];
    [invocation setTarget:self];
    [invocation invoke];

    double returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

- (void)performViewStateSelector:(SEL)aSelector
                         options:(DNStateOptions*)options
{
    if (aSelector == nil)   {   return; }

    [self performSelector:aSelector withObject:options];
}

#pragma clang diagnostic pop

@end
