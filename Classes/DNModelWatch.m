//
//  DNModelWatch.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNModelWatch.h"

#import "DNModel.h"

@interface DNModelWatch ()
{
    DNModel*    model;
}

@end

@implementation DNModelWatch

- (void)dealloc
{
    [self cancelWatch];
}

- (id)initWithModel:(DNModel*)myModel
{
    self = [super init];
    if (self)
    {
        model   = myModel;
    }
    
    return self;
}

- (void)startWatch
{
    [model retainWatch:self];
}

- (BOOL)checkWatch
{
    return [model checkWatch:self];
}

- (void)cancelWatch
{
    [model releaseWatch:self];
}

- (void)refreshWatch
{
}

- (void)executeWillChangeHandler:(NSDictionary*)context
{
}

- (void)executeDidChangeHandler:(NSDictionary*)context
{
}

- (void)executeDidChangeSectionInsertHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context
{
}

- (void)executeDidChangeSectionDeleteHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context
{
}

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
}

- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
}

- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
}

- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath*)newIndexPath
                                  context:(NSDictionary*)context
{
}

#pragma mark - private methods

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[[self class] managedObjectContext]
                blockAndWait:block];
}

- (void)performBlock:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[[self class] managedObjectContext]
                       block:block];
}

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext* context))block
{
    [model performWithContext:context
                 blockAndWait:block];
}

- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext* context))block
{
    [model performWithContext:context
                        block:block];
}

@end
