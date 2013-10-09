//
//  DNModel.m
//  Pods
//
//  Created by Darren Ehlers on 9/27/13.
//
//

#import "DNModel.h"

#import "DNManagedObject.h"
#import "DNModelWatchKVOObject.h"
#import "DNModelWatchKVOObjects.h"

@interface DNModel ()
{
    NSMutableArray* watches;
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

+ (instancetype)model
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        watches     = [NSMutableArray array];
    }
    
    return self;
}

- (void)saveContext
{
    [[self class] saveContext];
}

#pragma mark - model details

- (NSString*)getFromIDFetchTemplate     {   return [NSString stringWithFormat:@"a%@ByID", [[self class] entityName]];   }
- (NSString*)getAllFetchTemplate        {   return [NSString stringWithFormat:@"every%@", [[self class] entityName]];   }

- (NSArray*)getFromIDSortKeys   {   return @[ @"id" ];   }
- (NSArray*)getAllSortKeys      {   return @[ @"id" ];   }

#pragma mark - watch management

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                          onResult:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    DNModelWatchKVOObject*  watch   = [[DNModelWatchKVOObject alloc] initWithModel:self
                                                                         andObject:object
                                                                        andHandler:handler];
    
    return watch;
}

- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                            onResult:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    DNModelWatchKVOObjects*    watch   = [[DNModelWatchKVOObjects alloc] initWithModel:self
                                                                            andObjects:objects
                                                                            andHandler:handler];
    
    return watch;
}

- (void)retainWatch:(DNModelWatch*)watch
{
    [watches addObject:watch];
}

- (void)releaseWatch:(DNModelWatch*)watch
{
    [watches removeObject:watch];
}

#pragma mark - getFromID

- (DNModelWatchObject*)getFromID:(id)idValue onResult:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    NSDictionary*   substDict       = @{ @"ID": idValue };
    
    NSFetchRequest* fetchRequest    = [[[DNUtilities appDelegate] managedObjectModel] fetchRequestFromTemplateWithName:[self getFromIDFetchTemplate]
                                                                                                 substitutionVariables:substDict];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    NSMutableArray* sortDescriptors = [NSMutableArray array];
    
    [[self getFromIDSortKeys] enumerateObjectsUsingBlock:^(NSString* sortKey, NSUInteger idx, BOOL *stop)
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
    
    [fetchRequest setFetchLimit:1];
    
    return [DNModelWatchFetchedObject watchWithModel:self andFetch:fetchRequest andHandler:handler];
}

#pragma mark - getAll

- (DNModelWatchObjects*)getAllOnResult:(DNModelWatchObjectsDidChangeHandlerBlock)handler
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

    return [DNModelWatchFetchedObjects watchWithModel:self andFetch:fetchRequest andHandler:handler];
}

#pragma mark - deleteAll

- (void)deleteAll
{
    [self getAllOnResult:^(DNModelWatch* watch, NSArray* objects)
     {
         [objects enumerateObjectsUsingBlock:^(DNManagedObject* object, NSUInteger idx, BOOL *stop)
          {
              [object deleteWithNoSave];
          }];
         
         [self saveContext];
     }];
}

@end
