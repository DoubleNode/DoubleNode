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
        
        fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                     managedObjectContext:[[model class] managedObjectContext]
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:NSStringFromClass([self class])];
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
    [super startWatch];

    [self refreshWatch];

    if ([[self objects] count] > 0)
    {
        [self executeDidChangeHandler];
    }
}

- (void)cancelWatch
{
    [super cancelWatch];
    
    fetchRequest            = nil;
    fetchResultsController  = nil;
}

- (void)refreshWatch
{
    [super refreshWatch];
    
    NSError*    error = nil;
    
    fetchResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    
    BOOL    result = [fetchResultsController performFetch:&error];
    if (result == NO)
    {
        DLog(LL_Error, LD_CoreData, @"error=%@", [error localizedDescription]);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [self executeWillChangeHandler];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self executeDidChangeHandler];
}

- (void)controller:(NSFetchedResultsController*)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    //DLog(LL_Debug, LD_CoreData, @"controller:didChangeSection:atIndex:forChangeType:");
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self executeDidChangeSectionInsertHandler:sectionInfo atIndex:sectionIndex];
            break;
        }

        case NSFetchedResultsChangeDelete:
        {
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
    //DLog(LL_Debug, LD_CoreData, @"controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:");
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self executeDidChangeObjectInsertHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            [self executeDidChangeObjectDeleteHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath];
            break;
        }

        case NSFetchedResultsChangeUpdate:
        {
            [self executeDidChangeObjectUpdateHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath];
            break;
        }

        case NSFetchedResultsChangeMove:
        {
            [self executeDidChangeObjectMoveHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath];
            break;
        }
    }
}

@end
