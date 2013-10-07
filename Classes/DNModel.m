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
    NSMutableDictionary*    fetchWatches;
}

@end

@implementation DNModel

+ (NSString*)entityName     {   return nil;     }

#pragma mark - AppDelegate access functions

+ (id<DNApplicationDelegate>)appDelegate
{
    return (id<DNApplicationDelegate>)[[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext*)managedObjectContext
{
    return [[[self class] appDelegate] managedObjectContext];
}

+ (NSManagedObjectModel*)managedObjectModel
{
    return [[[self class] appDelegate] managedObjectModel];
}

+ (void)saveContext
{
    [[[self class] appDelegate] saveContext];
}

#pragma mark - initialization functions

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

- (DNModelWatch*)getAllOnResult:(getAll_resultsHandlerBlock)resultsHandler
{
    NSFetchRequest* fetchRequest    = [[[[DNUtilities appDelegate] managedObjectModel] fetchRequestTemplateForName:[self getAllFetchTemplate]] copy];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
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

    return [DNModelWatch_getAll watchWithFetch:fetchRequest andHandler:resultsHandler];
}

#pragma mark - deleteAll

- (void)deleteAll
{
    [self getAllOnResult:^(DNModelWatch* watch, NSArray* managedObjects)
     {
         [managedObjects enumerateObjectsUsingBlock:^(DNManagedObject* managedObject, NSUInteger idx, BOOL *stop)
          {
              [managedObject deleteWithNoSave];
          }];
     }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    //getAll_resultsHandler(nil, controller.fetchedObjects);
}

@end
