//
//  DNModelWatchObjects.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
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
}

- (void)executeWillChangeHandler
{
    [super executeWillChangeHandler];
    if ([self checkWatch] && (willChangeHandler != nil))
    {
        willChangeHandler(self, [self objects]);
    }
}

- (void)executeDidChangeHandler
{
    [super executeDidChangeHandler];
    if ([self checkWatch] && (didChangeHandler != nil))
    {
         didChangeHandler(self, [self objects]);
    }
}

@end
