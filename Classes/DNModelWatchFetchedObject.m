//
//  DNModelWatchFetchedObject.m
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNModelWatchFetchedObject.h"

@interface DNModelWatchFetchedObject () <NSFetchedResultsControllerDelegate>
{
    NSFetchRequest*             fetchRequest;
    NSFetchedResultsController* fetchResultsController;
}

@end

@implementation DNModelWatchFetchedObject

+ (id)watchWithModel:(DNModel*)model
            andFetch:(NSFetchRequest*)fetch
          andHandler:(DNModelWatchObject_resultsHandlerBlock)resultsHandler
{
    return [[DNModelWatchFetchedObject alloc] initWithModel:model andFetch:fetch andHandler:resultsHandler];
}

- (id)initWithModel:(DNModel*)model
           andFetch:(NSFetchRequest*)fetch
         andHandler:(DNModelWatchObject_resultsHandlerBlock)handler
{
    self = [super initWithModel:model andHandler:handler];
    if (self)
    {
        fetchRequest    = fetch;
        
        fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                     managedObjectContext:[[DNUtilities appDelegate] managedObjectContext]
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:NSStringFromClass([self class])];
        fetchResultsController.delegate = self;

        [self refreshWatch];

        if ([fetchResultsController.fetchedObjects count] > 0)
        {
            [self executeResultsHandler];
        }
    }
    
    return self;
}

- (DNManagedObject*)object
{
    if ([fetchResultsController.fetchedObjects count] == 0)
    {
        return nil;
    }
    
    return fetchResultsController.fetchedObjects[0];
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

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self executeResultsHandler];
}

/*
- (void)controller:(NSFetchedResultsController*)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    //DLog(LL_Debug, LD_CoreData, @"controller:didChangeSection:atIndex:forChangeType:");
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            break;
            
        case NSFetchedResultsChangeDelete:
            break;
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
            break;
            
        case NSFetchedResultsChangeDelete:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}
*/

@end
