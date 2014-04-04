//
//  DNModelWatchFetchedObjects.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNModelWatchFetchedObjects.h"

@interface DNModelWatchFetchedObjects () <NSFetchedResultsControllerDelegate>
{
    NSFetchRequest*             fetchRequest;
    NSFetchedResultsController* fetchResultsController;
}

@end

@implementation DNModelWatchFetchedObjects

+ (id)watchWithModel:(DNModel*)model
            andFetch:(NSFetchRequest*)fetch
{
    return [[DNModelWatchFetchedObjects alloc] initWithModel:model andFetch:fetch];
}

- (id)initWithModel:(DNModel*)model
           andFetch:(NSFetchRequest*)fetch
{
    self = [super initWithModel:model];
    if (self)
    {
        fetchRequest    = fetch;

        [self performWithContext:[[model class] managedObjectContext]
                    blockAndWait:^(NSManagedObjectContext* context)
         {
             NSAssert(context != nil, @"context is NIL");
             NSAssert(fetchRequest != nil, @"fetchRequest is NIL");

             fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:context
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:nil];    //NSStringFromClass([self class])];
         }];

        fetchResultsController.delegate = self;
    }
    
    return self;
}

- (NSArray*)objects
{
    return fetchResultsController.fetchedObjects;
}

- (void)startWatch
{
    if ([self checkWatch])
    {
        return;
    }

    [super startWatch];

    [self refreshWatch];

    if ([[self objects] count] > 0)
    {
        [self executeWillChangeHandler];
        [[self objects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
         {
             NSIndexPath*   indexPath   = [NSIndexPath indexPathForRow:idx inSection:0];
             [self executeDidChangeObjectInsertHandler:obj atIndexPath:indexPath newIndexPath:indexPath];
         }];
        [self executeDidChangeHandler];
    }
}

- (void)cancelWatch
{
    NSArray*    objects = [self objects];

    fetchRequest                    = nil;
    fetchResultsController.delegate = nil;
    fetchResultsController          = nil;

    if ([objects count] > 0)
    {
        [self executeWillChangeHandler];
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
         {
             NSIndexPath*   indexPath   = [NSIndexPath indexPathForRow:idx inSection:0];
             [self executeDidChangeObjectDeleteHandler:obj atIndexPath:indexPath newIndexPath:indexPath];
         }];

        [self executeDidChangeHandler];
    }

    [super cancelWatch];
}

- (void)refreshWatch
{
    [super refreshWatch];
    
    fetchResultsController.fetchRequest.resultType = NSManagedObjectResultType;

    [self performWithContext:[fetchResultsController managedObjectContext]
                       block:^(NSManagedObjectContext* context)
     {
         NSError*    error = nil;

         BOOL   result = [fetchResultsController performFetch:&error];
         if (result == NO)
         {
             DLog(LL_Error, LD_CoreData, @"error=%@", [error localizedDescription]);
         }
     }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    //DLog(LL_Debug, LD_CoreData, @"controllerWillChangeContent:");
    [self executeWillChangeHandler];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    //DLog(LL_Debug, LD_CoreData, @"controllerDidChangeContent:");
    [self executeDidChangeHandler];
}

- (void)controller:(NSFetchedResultsController*)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    //DLog(LL_Debug, LD_CoreData, @"controller:didChangeSection:atIndex:%d forChangeType:", sectionIndex);
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeInsert", sectionIndex);
            [self executeDidChangeSectionInsertHandler:sectionInfo atIndex:sectionIndex];
            break;
        }

        case NSFetchedResultsChangeDelete:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeDelete", sectionIndex);
            [self executeDidChangeSectionDeleteHandler:sectionInfo atIndex:sectionIndex];
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath*)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeInsert newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectInsertHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeDelete newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectDeleteHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath];
            break;
        }

        case NSFetchedResultsChangeUpdate:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeUpdate newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectUpdateHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath];
            break;
        }

        case NSFetchedResultsChangeMove:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeMove newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectMoveHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath];
            break;
        }
    }
}

@end
