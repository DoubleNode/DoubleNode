//
//  DNModel.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNModel.h"

#import "DNDataModel.h"
#import "DNManagedObject.h"
#import "DNModelWatchKVOObject.h"
#import "DNModelWatchKVOObjects.h"

@interface DNModel ()
{
    NSMutableArray* watches;
}

@end

@implementation DNModel

+ (id)dataModel
{
    return [[self dataModelClass] dataModel];
}

+ (Class)dataModelClass
{
    return [DNDataModel class];
}

+ (NSString*)dataModelName
{
    return [[self class] dataModelName];
}

+ (NSString*)entityName
{
    // Assume a 2-character prefix to class name and the 5 character "Model" suffix
    return [NSStringFromClass([self class]) substringWithRange:NSMakeRange(2, [NSStringFromClass([self class]) length] - 7)];
}

#pragma mark - AppDelegate access functions

+ (NSManagedObjectContext*)managedObjectContext
{
    return [[self dataModel] mainObjectContext];
}

+ (void)saveContext
{
    [[self dataModel] saveContext];
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
    
    __block NSArray*    resultArray;
    
    [self performBlockAndWait:^(NSManagedObjectContext* context)
     {
         @try
         {
             NSError*    error;

             resultArray  = [context executeFetchRequest:fetchRequest error:&error];
             if ([resultArray count] == 0)
             {
                 resultArray    = nil;
                 return;
             }
         }
         @catch (NSException *exception)
         {
             DLog(LL_Error, LD_CoreData, @"Unable to execute fetchRequest (%@)", exception);
             resultArray    = nil;
             return;
         }
     }];

    if ([resultArray count] == 0)
    {
        return nil;
    }

    return [resultArray objectAtIndex:0];
}

- (DNModelWatchObject*)watchFromID:(id)idValue
{
    NSFetchRequest* fetchRequest    = [self getFromID_FetchRequest:idValue];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    return [DNModelWatchFetchedObject watchWithModel:self andFetch:fetchRequest];
}

- (NSPredicate*)getFromID_FetchRequestPredicate:(id)idValue
{
    return [NSPredicate predicateWithFormat:@"id == %@", idValue];
}

- (NSFetchRequest*)getFromID_FetchRequest:(id)idValue
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[[self class] entityName]];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to create fetchRequest");
        return nil;
    }
    
    [fetchRequest setPredicate:[self getFromID_FetchRequestPredicate:idValue]];
    
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
    
    __block NSArray*    resultArray;

    [self performBlockAndWait:^(NSManagedObjectContext* context)
     {
         @try
         {
             NSError*    error;

             resultArray  = [context executeFetchRequest:fetchRequest error:&error];
             if ([resultArray count] == 0)
             {
                 resultArray = nil;
                 return;
             }
         }
         @catch (NSException *exception)
         {
             DLog(LL_Error, LD_CoreData, @"Unable to execute fetchRequest (%@)", exception);
             resultArray = nil;
             return;
         }
     }];

    return resultArray;
}

- (DNModelWatchObjects*)watchAll
{
    NSFetchRequest* fetchRequest    = [self getAll_FetchRequest];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    return [DNModelWatchFetchedObjects watchWithModel:self andFetch:fetchRequest];
}

- (NSFetchRequest*)getAll_FetchRequest
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[[self class] entityName]];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to create fetchRequest");
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

#pragma mark - private methods

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[[self class] managedObjectContext]
                blockAndWait:block];
}

- (void)performBlock:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[[self class] managedObjectContext]
                       block:block];
}

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext* context))block
{
    [[[self class] dataModel] performWithContext:context
                                    blockAndWait:block];
}

- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext* context))block
{
    [[[self class] dataModel] performWithContext:context
                                           block:block];
}

@end
