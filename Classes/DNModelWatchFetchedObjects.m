//
//  DNModelWatchFetchedObjects.m
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
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
          andHandler:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    return [[DNModelWatchFetchedObjects alloc] initWithModel:model andFetch:fetch andHandler:handler];
}

- (id)initWithModel:(DNModel*)model
           andFetch:(NSFetchRequest*)fetch
         andHandler:(DNModelWatchObjectsDidChangeHandlerBlock)handler
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

        if ([[self objects] count] > 0)
        {
            [self executeDidChangeHandler];
        }
    }
    
    return self;
}

- (NSArray*)objects
{
    return fetchResultsController.fetchedObjects;
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
