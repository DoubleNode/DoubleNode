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
    DNModelWatchObjectsDidChangeHandlerBlock    didChangeHandler;
}

@end

@implementation DNModelWatchObjects

- (id)initWithModel:(DNModel*)model
         andHandler:(DNModelWatchObjectsDidChangeHandlerBlock)handler
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
    
    didChangeHandler    = nil;
}

- (void)executeDidChangeHandler
{
    if (didChangeHandler)
    {
        didChangeHandler(self, [self objects]);
    }
}

@end
