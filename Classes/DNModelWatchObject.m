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
}

@end

@implementation DNModelWatchObject

- (id)initWithModel:(DNModel*)model
{
    self = [super initWithModel:model];
    if (self)
    {
    }
    
    return self;
}

- (DNManagedObject*)object;
{
    return nil;
}

- (void)executeWillChangeHandler
{
    [super executeWillChangeHandler];
    if ([self checkWatch] && (self.willChangeHandler != nil))
    {
        self.willChangeHandler(self, [self object]);
    }
}

- (void)executeDidChangeHandler
{
    [super executeDidChangeHandler];
    if ([self checkWatch] && (self.didChangeHandler != nil))
    {
        self.didChangeHandler(self, [self object]);
    }
}

@end
