//
//  DNModelWatchFetchedObject.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
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
{
    return [[DNModelWatchFetchedObject alloc] initWithModel:model andFetch:fetch];
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
             fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:context
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:NSStringFromClass([self class])];
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
    [super startWatch];

    [self refreshWatch];

    if ([[self objects] count] > 0)
    {
        [self executeDidChangeHandler];
    }
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
