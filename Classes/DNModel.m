//
//  DNModel.m
//  Pods
//
//  Created by Darren Ehlers on 9/27/13.
//
//

#import "DNModel.h"

#import "DNManagedObject.h"

#import "DNModelWatch_getAll.h"

@interface DNModel () <NSFetchedResultsControllerDelegate>
{
    NSMutableDictionary*            fetchWatches;
    
    getFromID_resultsHandlerBlock   getFromID_resultsHandler;
}

@end

@implementation DNModel

+ (NSString*)entityName     {   return nil;     }

- (id)init
{
    self = [super init];
    if (self)
    {
        fetchWatches    = [NSMutableDictionary dictionary];
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
    
    NSMutableArray* sortDescriptors = [NSMutableArray array];
    [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController* fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[[DNUtilities appDelegate] managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    fetchedResultsController.delegate = self;
    [fetchWatches setObject:fetchedResultsController forKey:@"getFromID"];
    
    fetchedResultsController.fetchRequest.resultType = NSManagedObjectResultType;
    [fetchedResultsController performFetch:nil];
}

#pragma mark - getAll

- (DNModelWatch*)getAllWatchKey:(NSString*)watchKey
                       onResult:(getAll_resultsHandlerBlock)resultsHandler
{
    NSFetchRequest* fetchRequest    = [[[[DNUtilities appDelegate] managedObjectModel] fetchRequestTemplateForName:[self getAllFetchTemplate]] copy];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
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
    
    DNModelWatch_getAll*    watch   = [DNModelWatch_getAll watchWithFetch:fetchRequest andHandler:resultsHandler];
    
    [fetchWatches setObject:watch forKey:watchKey];
    
    return watch;
}

#pragma mark - deleteAll

- (void)deleteAll
{
    [self getAllWatchKey:@"deleteAll" onResult:^(DNModelWatch* watch, NSArray* managedObjects)
     {
         [fetchWatches removeObjectForKey:@"deleteAll"];

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
    //getAll_resultsHandler(nil, controller.fetchedObjects);
}

@end
