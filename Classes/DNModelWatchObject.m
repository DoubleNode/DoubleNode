//
//  DNModelWatchObject.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
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
    if ([self checkWatch] && (willChangeHandler != nil))
    {
        willChangeHandler(self, [self object]);
    }
}

- (void)executeDidChangeHandler
{
    [super executeDidChangeHandler];
    if ([self checkWatch] && (didChangeHandler != nil))
    {
        didChangeHandler(self, [self object]);
    }
}

@end
