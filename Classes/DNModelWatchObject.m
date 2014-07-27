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

- (void)executeWillChangeHandler:(NSDictionary*)context
{
    [super executeWillChangeHandler:context];
    if ([self checkWatch] && (self.willChangeHandler != nil))
    {
        self.willChangeHandler(self, [self object], context);
    }
}

- (void)executeDidChangeHandler:(NSDictionary*)context
{
    [super executeDidChangeHandler:context];
    if ([self checkWatch] && (self.didChangeHandler != nil))
    {
        self.didChangeHandler(self, [self object], context);
    }
}

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    [super executeDidChangeObjectInsertHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
    if ([self checkWatch] && (self.didChangeObjectInsertHandler != nil))
    {
        self.didChangeObjectInsertHandler(self, object, context);
    }
}

- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    [super executeDidChangeObjectDeleteHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
    if ([self checkWatch] && (self.didChangeObjectDeleteHandler != nil))
    {
        self.didChangeObjectDeleteHandler(self, object, context);
    }
}

- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    [super executeDidChangeObjectUpdateHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
    if ([self checkWatch] && (self.didChangeObjectUpdateHandler != nil))
    {
        self.didChangeObjectUpdateHandler(self, object, context);
    }
}

- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath*)newIndexPath
                                  context:(NSDictionary*)context
{
    [super executeDidChangeObjectMoveHandler:object
                                 atIndexPath:indexPath
                                newIndexPath:newIndexPath
                                     context:context];
    if ([self checkWatch] && (self.didChangeObjectMoveHandler != nil))
    {
        self.didChangeObjectMoveHandler(self, object, context);
    }
}

@end
