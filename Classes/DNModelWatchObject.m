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
    DNModelWatchObjectWillChangeHandlerBlock    willChangeHandler;
    DNModelWatchObjectDidChangeHandlerBlock     didChangeHandler;
}

@end

@implementation DNModelWatchObject

- (id)initWithModel:(DNModel*)model
          didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
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

- (void)executeWillChangeHandler
{
    [super executeWillChangeHandler];
    if (willChangeHandler)
    {
        willChangeHandler(self, [self object]);
    }
}

- (void)executeDidChangeHandler
{
    [super executeDidChangeHandler];
    if (didChangeHandler)
    {
        didChangeHandler(self, [self object]);
    }
}

@end
