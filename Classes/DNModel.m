//
//  DNModel.m
//  Pods
//
//  Created by Darren Ehlers on 9/27/13.
//
//

#import <CoreData/CoreData.h>

#import "DNModel.h"
#import "DNManagedObject.h"

@interface DNModel () <NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController*     fetchedResultsController;
    
    getAll_resultsHandlerBlock      getAll_resultsHandler;
}

@end

@implementation DNModel

#pragma mark - model details

- (NSString*)getAllFetchTemplate
{
    return @"";
}

- (NSArray*)getAllSortKeys
{
    return @[  ];
}

#pragma mark - getAll

- (void)getAllRefetchData
{
    fetchedResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [fetchedResultsController performFetch:nil];
}

- (void)getAllOnResult:(getAll_resultsHandlerBlock)resultsHandler
{
    getAll_resultsHandler   = resultsHandler;
    
    NSFetchRequest* fetchRequest    = [[[[DNUtilities appDelegate] managedObjectModel] fetchRequestTemplateForName:[self getAllFetchTemplate]] copy];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return;
    }
    
    NSMutableArray* sortDescriptors = [NSMutableArray array];
    
    [[self getAllSortKeys] enumerateObjectsUsingBlock:^(NSString* sortKey, NSUInteger idx, BOOL *stop)
     {
         if ((sortKey != nil) && ([sortKey length] > 0))
         {
             [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES]];
         }
     }];
    if ([sortDescriptors count] > 0)
    {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:[[DNUtilities appDelegate] managedObjectContext]
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:nil];
}

#pragma mark - deleteAll

- (void)deleteAll
{
    [self getAllOnResult:^(NSArray* managedObjects)
     {
         [managedObjects enumerateObjectsUsingBlock:^(DNManagedObject* managedObject, NSUInteger idx, BOOL *stop)
          {
              [managedObject deleteWithNoSave];
          }];
         
         [DNManagedObject saveContext];
     }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    getAll_resultsHandler(fetchedResultsController.fetchedObjects);
}

@end
