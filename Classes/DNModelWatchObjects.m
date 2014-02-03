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

/*
- (id)initWithModel:(DNModel*)model
         willChange:(DNModelWatchObjectsWillChangeHandlerBlock)willChangeHandler
          didChange:(DNModelWatchObjectsDidChangeHandlerBlock)didChangeHandler
{
    self = [self initWithModel:model];
    if (self)
    {
        self.willChangeHandler  = willChangeHandler;
        self.didChangeHandler   = didChangeHandler;
    }
    
    return self;
}
*/

- (NSArray*)objects
{
    return nil;
}

- (void)executeWillChangeHandler
{
    [super executeWillChangeHandler];
    if ([self checkWatch] && (self.willChangeHandler != nil))
    {
        self.willChangeHandler(self, [self objects]);
    }
}

- (void)executeDidChangeHandler
{
    [super executeDidChangeHandler];
    if ([self checkWatch] && (self.didChangeHandler != nil))
    {
         self.didChangeHandler(self, [self objects]);
    }
}

- (void)executeDidChangeSectionInsertHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
{
    [super executeDidChangeSectionInsertHandler:sectionInfo
                                        atIndex:sectionIndex];
    if ([self checkWatch] && (self.didChangeSectionInsertHandler != nil))
    {
        self.didChangeSectionInsertHandler(self, sectionInfo, sectionIndex);
    }
}

- (void)executeDidChangeSectionDeleteHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
{
    [super executeDidChangeSectionDeleteHandler:sectionInfo
                                        atIndex:sectionIndex];
    if ([self checkWatch] && (self.didChangeSectionDeleteHandler != nil))
    {
        self.didChangeSectionDeleteHandler(self, sectionInfo, sectionIndex);
    }
}

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath
{
    [super executeDidChangeObjectInsertHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath];
    if ([self checkWatch] && (self.didChangeObjectInsertHandler != nil))
    {
        self.didChangeObjectInsertHandler(self, object, indexPath, newIndexPath);
    }
}

- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath
{
    [super executeDidChangeObjectDeleteHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath];
    if ([self checkWatch] && (self.didChangeObjectDeleteHandler != nil))
    {
        self.didChangeObjectDeleteHandler(self, object, indexPath, newIndexPath);
    }
}

- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath
{
    [super executeDidChangeObjectUpdateHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath];
    if ([self checkWatch] && (self.didChangeObjectUpdateHandler != nil))
    {
        self.didChangeObjectUpdateHandler(self, object, indexPath, newIndexPath);
    }
}

- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath *)newIndexPath
{
    [super executeDidChangeObjectMoveHandler:object
                                 atIndexPath:indexPath
                                newIndexPath:newIndexPath];
    if ([self checkWatch] && (self.didChangeObjectMoveHandler != nil))
    {
        self.didChangeObjectMoveHandler(self, object, indexPath, newIndexPath);
    }
}

@end
