//
//  DNModel.m
//  Pods
//
//  Created by Darren Ehlers on 9/27/13.
//
//

#import "DNModel.h"

#import "DNManagedObject.h"

@interface DNModel () <NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController*     fetchedResultsController;
    
    getAll_resultsHandlerBlock      getAll_resultsHandler;
}

@end

@implementation DNModel

+ (NSString*)entityName     {   return nil;     }

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

#pragma mark - model details

- (NSString*)getFromIDFetchTemplate     {   return [NSString stringWithFormat:@"a%@ByID", [[self class] entityName]];   }
- (NSString*)getAllFetchTemplate        {   return [NSString stringWithFormat:@"every%@", [[self class] entityName]];   }

- (NSArray*)getAllSortKeys      {   return @[ @"id" ];   }

#pragma mark - getFromID

- (void)getFromID:(id)idValue onResult:(getFromID_resultsHandlerBlock)resultsHandler
{
    NSDictionary*   substDict       = @{ @"ID": idValue };
    
    NSFetchRequest* fetchRequest    = [[[DNUtilities appDelegate] managedObjectModel] fetchRequestFromTemplateWithName:[self getFromIDFetchTemplate]
                                                                                                 substitutionVariables:substDict];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return;
    }
    
    [fetchRequest setFetchLimit:1];
    
    NSError*    error;
    NSArray*    resultArray = [[[DNUtilities appDelegate] managedObjectContext] executeFetchRequest:fetchRequest
                                                                                              error:&error];
    if ([resultArray count] == 0)
    {
        resultsHandler(nil);
    }
    else
    {
        resultsHandler([resultArray objectAtIndex:0]);
    }
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
