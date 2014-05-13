//
//  DNModelWatchObject.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
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

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
{
    [super executeDidChangeObjectInsertHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath];
    if ([self checkWatch] && (self.didChangeObjectInsertHandler != nil))
    {
        self.didChangeObjectInsertHandler(self, object);
    }
}

- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
{
    [super executeDidChangeObjectDeleteHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath];
    if ([self checkWatch] && (self.didChangeObjectDeleteHandler != nil))
    {
        self.didChangeObjectDeleteHandler(self, object);
    }
}

- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
{
    [super executeDidChangeObjectUpdateHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath];
    if ([self checkWatch] && (self.didChangeObjectUpdateHandler != nil))
    {
        self.didChangeObjectUpdateHandler(self, object);
    }
}

- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath*)newIndexPath
{
    [super executeDidChangeObjectMoveHandler:object
                                 atIndexPath:indexPath
                                newIndexPath:newIndexPath];
    if ([self checkWatch] && (self.didChangeObjectMoveHandler != nil))
    {
        self.didChangeObjectMoveHandler(self, object);
    }
}

@end
