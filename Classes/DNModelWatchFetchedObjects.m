//
//  DNModelWatchFetchedObjects.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNModelWatchFetchedObjects.h"

@interface DNModelWatchFetchedObjects () <NSFetchedResultsControllerDelegate>
{
    NSFetchRequest*             fetchRequest;
    NSFetchedResultsController* fetchResultsController;

    BOOL    forceNoObjects;
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
    if (forceNoObjects)
    {
        return @[];
    }

    return fetchResultsController.fetchedObjects;
}

- (void)startWatch
{
    if ([self checkWatch])
    {
        return;
    }

    [super startWatch];

    [self performWithContext:[fetchResultsController managedObjectContext]
                       block:^(NSManagedObjectContext* context)
     {
         [self refreshWatch];

         if ([[self objects] count] > 0)
         {
             forceNoObjects  = YES;
             [self executeWillChangeHandler:nil];
             forceNoObjects  = NO;
             [[self objects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
              {
                  NSIndexPath*   indexPath   = [NSIndexPath indexPathForRow:idx inSection:0];
                  [self executeDidChangeObjectInsertHandler:obj atIndexPath:indexPath newIndexPath:indexPath context:nil];
              }];
             [self executeDidChangeHandler:nil];
         }
     }];
}

- (void)cancelWatch
{
    NSArray*    objects = [self objects];

    fetchRequest                    = nil;
    fetchResultsController.delegate = nil;
    fetchResultsController          = nil;

    if ([objects count] > 0)
    {
        [self executeWillChangeHandler:nil];
        forceNoObjects  = YES;
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
         {
             NSIndexPath*   indexPath   = [NSIndexPath indexPathForRow:idx inSection:0];
             [self executeDidChangeObjectDeleteHandler:obj atIndexPath:indexPath newIndexPath:indexPath context:nil];
         }];

        [self executeDidChangeHandler:nil];
        forceNoObjects  = NO;
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
    [self executeWillChangeHandler:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    //DLog(LL_Debug, LD_CoreData, @"controllerDidChangeContent:");
    [self executeDidChangeHandler:nil];
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
            [self executeDidChangeSectionInsertHandler:sectionInfo atIndex:sectionIndex context:nil];
            break;
        }

        case NSFetchedResultsChangeDelete:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeDelete", sectionIndex);
            [self executeDidChangeSectionDeleteHandler:sectionInfo atIndex:sectionIndex context:nil];
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
            [self executeDidChangeObjectInsertHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeDelete newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectDeleteHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }

        case NSFetchedResultsChangeUpdate:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeUpdate newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectUpdateHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }

        case NSFetchedResultsChangeMove:
        {
            //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeMove newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectMoveHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }
    }
}

@end
