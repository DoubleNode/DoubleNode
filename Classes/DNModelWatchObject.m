//
//  DNModelWatchObject.m
//  Pods
//
//  Created by Darren Ehlers on 10/8/13.
//
//

#import "DNModelWatchObject.h"

@interface DNModelWatchObject ()
{
    DNModelWatchObjectDidChangeHandlerBlock  didChangeHandler;
}

@end

@implementation DNModelWatchObject

- (id)initWithModel:(DNModel*)model
         andHandler:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    self = [super initWithModel:model];
    if (self)
    {
        didChangeHandler  = handler;
    }
    
    return self;
}

- (DNManagedObject*)object;
{
    return nil;
}

- (void)cancelWatch
{
    [super cancelWatch];
    
    didChangeHandler    = nil;
}

- (void)executeDidChangeHandler
{
    if (didChangeHandler)
    {
        didChangeHandler(self, [self object]);
    }
}

@end
