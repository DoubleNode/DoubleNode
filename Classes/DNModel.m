//
//  DNModel.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
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
                         didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    DNModelWatchKVOObject*  watch   = [[DNModelWatchKVOObject alloc] initWithModel:self
                                                                         andObject:object
                                                                     andAttributes:nil
                                                                         didChange:handler];
    
    return watch;
}

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                     andAttributes:(NSArray*)attributes
                         didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    DNModelWatchKVOObject*  watch   = [[DNModelWatchKVOObject alloc] initWithModel:self
                                                                         andObject:object
                                                                     andAttributes:attributes
                                                                         didChange:handler];
    
    return watch;
}

- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    DNModelWatchKVOObjects*    watch   = [[DNModelWatchKVOObjects alloc] initWithModel:self
                                                                            andObjects:objects
                                                                         andAttributes:nil
                                                                             didChange:handler];
    
    return watch;
}

- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                       andAttributes:(NSArray*)attributes
                           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    DNModelWatchKVOObjects*    watch   = [[DNModelWatchKVOObjects alloc] initWithModel:self
                                                                            andObjects:objects
                                                                         andAttributes:attributes
                                                                             didChange:handler];
    
    return watch;
}

- (BOOL)checkWatch:(DNModelWatch*)watch
{
    return [watches containsObject:watch];
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

- (id)getFromID:(id)idValue
{
    NSFetchRequest* fetchRequest    = [self getFromID_FetchRequest:idValue];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    NSError*    error;
    NSArray*    resultArray;
    
    @try
    {
        resultArray  = [[[self class] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if ([resultArray count] == 0)
        {
            return nil;
        }
    }
    @catch (NSException *exception)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to execute fetchRequest (%@)", exception);
    }
    
    return [resultArray objectAtIndex:0];
}

- (DNModelWatchObject*)getFromID:(id)idValue
                       didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    NSFetchRequest* fetchRequest    = [self getFromID_FetchRequest:idValue];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    return [DNModelWatchFetchedObject watchWithModel:self andFetch:fetchRequest didChange:handler];
}

- (NSFetchRequest*)getFromID_FetchRequest:(id)idValue
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
    
    return fetchRequest;
}

#pragma mark - getAll

- (NSArray*)getAll
{
    NSFetchRequest* fetchRequest    = [self getAll_FetchRequest];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    NSError*    error;
    NSArray*    resultArray;
    
    @try
    {
        resultArray  = [[[self class] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if ([resultArray count] == 0)
        {
            return nil;
        }
    }
    @catch (NSException *exception)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to execute fetchRequest (%@)", exception);
    }
    
    return [resultArray objectAtIndex:0];
}

- (DNModelWatchObjects*)getAllDidChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    NSFetchRequest* fetchRequest    = [self getAll_FetchRequest];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    return [DNModelWatchFetchedObjects watchWithModel:self andFetch:fetchRequest didChange:handler];
}

- (NSFetchRequest*)getAll_FetchRequest
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
    
    return fetchRequest;
}

#pragma mark - deleteAll

- (void)deleteAllWithCompletion:(DNModelCompletionHandlerBlock)handler;
{
    [[self getAll] enumerateObjectsUsingBlock:^(DNManagedObject* object, NSUInteger idx, BOOL *stop)
     {
         [object deleteWithNoSave];
     }];
    
    [self saveContext];
         
     if (handler != nil)
     {
         handler();
     }
}

@end
