//
//  DNModelWatch_getAll.m
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNModelWatch_getAll.h"

@interface DNModelWatch_getAll () <NSFetchedResultsControllerDelegate>
{
    NSFetchRequest*             fetchRequest;
    NSFetchedResultsController* fetchResultsController;
    
    getAll_resultsHandlerBlock  resultsHandler;
}

@end

@implementation DNModelWatch_getAll

+ (id)watchWithFetch:(NSFetchRequest*)fetch
          andHandler:(getAll_resultsHandlerBlock)resultsHandler
{
    return [[DNModelWatch_getAll alloc] initWithFetch:fetch andHandler:resultsHandler];
}

- (id)initWithFetch:(NSFetchRequest*)fetch
         andHandler:(getAll_resultsHandlerBlock)handler
{
    self = [super init];
    if (self)
    {
        fetchRequest    = fetch;
        resultsHandler  = handler;
        
        fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                     managedObjectContext:[[DNUtilities appDelegate] managedObjectContext]
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
        fetchResultsController.delegate = self;
        [self performFetch:nil];

        //DLog(LL_Debug, LD_CoreData, @"fetchedObjects=%@", fetchResultsController.fetchedObjects);
        if ([fetchResultsController.fetchedObjects count] > 0)
        {
            [self executeResultsHandler:fetchResultsController.fetchedObjects];
        }
    }
    
    return self;
}

- (void)cancelFetch
{
    [super cancelFetch];
    
    fetchRequest            = nil;
    fetchResultsController  = nil;
    resultsHandler          = nil;
}

- (void)performFetch:(NSError **)error
{
    [super performFetch:error];
    
    fetchResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [fetchResultsController performFetch:error];
}

- (void)executeResultsHandler:(NSArray*)entities
{
    if (resultsHandler)
    {
        resultsHandler(self, entities);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self executeResultsHandler:controller.fetchedObjects];
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

@end
