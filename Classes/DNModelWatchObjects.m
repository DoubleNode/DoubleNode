//
//  DNModelWatchObjects.m
//  Pods
//
//  Created by Darren Ehlers on 10/8/13.
//
//

#import "DNModelWatchObjects.h"

@interface DNModelWatchObjects ()
{
    DNModelWatchObjectsWillChangeHandlerBlock   willChangeHandler;
    DNModelWatchObjectsDidChangeHandlerBlock    didChangeHandler;
}

@end

@implementation DNModelWatchObjects

- (id)initWithModel:(DNModel*)model
          didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    self = [super initWithModel:model];
    if (self)
    {
        didChangeHandler  = handler;
    }
    
    return self;
}

- (NSArray*)objects
{
    return nil;
}

- (void)cancelWatch
{
    [super cancelWatch];
    
    willChangeHandler   = nil;
    didChangeHandler    = nil;
}

- (void)executeWillChangeHandler
{
    if (willChangeHandler)
    {
        willChangeHandler(self, [self objects]);
    }
}

- (void)executeDidChangeHandler
{
    if (didChangeHandler)
    {
        didChangeHandler(self, [self objects]);
    }
}

@end
