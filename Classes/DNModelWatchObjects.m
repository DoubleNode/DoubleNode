//
//  DNModelWatchObjects.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNModelWatchObjects.h"

@interface DNModelWatchObjects ()
{
}

@end

@implementation DNModelWatchObjects

- (id)initWithModel:(DNModel*)model
{
    self = [super initWithModel:model];
    if (self)
    {
    }

    return self;
}

- (NSArray*)sections
{
    return nil;
}

- (id<NSFetchedResultsSectionInfo>)section:(NSUInteger)sectionNdx
{
    return nil;
}

- (NSString*)sectionName:(NSUInteger)sectionNdx
{
    return @"";
}

- (NSString*)sectionIndexTitle:(NSUInteger)sectionNdx
{
    return @"";
}

- (NSArray*)objects
{
    return nil;
}

- (NSArray*)objectsForSection:(NSUInteger)section
{
    return nil;
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    return nil;
}

- (void)executeWillChangeHandler:(NSDictionary*)context
{
    [super executeWillChangeHandler:context];
    if ([self checkWatch] && (self.willChangeHandler != nil))
    {
        self.willChangeHandler(self, [self objects], context);
    }
}

- (void)executeDidChangeHandler:(NSDictionary*)context
{
    [super executeDidChangeHandler:context];
    if ([self checkWatch] && (self.didChangeHandler != nil))
    {
        self.didChangeHandler(self, [self objects], context);
    }
}

- (void)executeDidChangeSectionInsertHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context
{
    [super executeDidChangeSectionInsertHandler:sectionInfo
                                        atIndex:sectionIndex
                                        context:context];
    if ([self checkWatch] && (self.didChangeSectionInsertHandler != nil))
    {
        self.didChangeSectionInsertHandler(self, sectionInfo, sectionIndex, context);
    }
}

- (void)executeDidChangeSectionDeleteHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context
{
    [super executeDidChangeSectionDeleteHandler:sectionInfo
                                        atIndex:sectionIndex
                                        context:context];
    if ([self checkWatch] && (self.didChangeSectionDeleteHandler != nil))
    {
        self.didChangeSectionDeleteHandler(self, sectionInfo, sectionIndex, context);
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
        self.didChangeObjectInsertHandler(self, object, newIndexPath, context);
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
        self.didChangeObjectDeleteHandler(self, object, indexPath, context);
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
        self.didChangeObjectUpdateHandler(self, object, indexPath, context);
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
        self.didChangeObjectMoveHandler(self, object, indexPath, newIndexPath, context);
    }
}

- (BOOL)executeShouldChangeObjectUpdateHandler:(id)object
                                   atIndexPath:(NSIndexPath*)indexPath
                                  newIndexPath:(NSIndexPath*)newIndexPath
                                       context:(NSDictionary*)context
{
    BOOL retval = [super executeShouldChangeObjectUpdateHandler:object
                                                    atIndexPath:indexPath
                                                   newIndexPath:newIndexPath
                                                        context:context];
    if ([self checkWatch] && (self.shouldChangeObjectUpdateHandler != nil))
    {
        retval = self.shouldChangeObjectUpdateHandler(self, object, indexPath, context);
    }
    
    return retval;
}

@end
