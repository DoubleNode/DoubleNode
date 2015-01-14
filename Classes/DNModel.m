//
//  DNModel.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
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

+ (NSArray*)globalWatchesArray
{
    static dispatch_once_t  once;
    static NSMutableArray*  instance = nil;
    
    dispatch_once(&once, ^{
        instance = [NSMutableArray array];
    });
    
    return instance;
}

+ (void)addGlobalWatch:(DNModelWatch*)watch
{
    NSMutableArray* array   = (NSMutableArray*)[self globalWatchesArray];
    
    @synchronized(array)
    {
        [array addObject:watch];
    }
}

+ (void)removeGlobalWatch:(DNModelWatch*)watch
{
    NSMutableArray* array   = (NSMutableArray*)[self globalWatchesArray];
    
    @synchronized(array)
    {
        [array removeObject:watch];
    }
}

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
    return [self dataModelName];
}

+ (NSString*)entityName
{
    // Assume a 2-character prefix to class name and the 5 character "Model" suffix
    return [NSStringFromClass([self class]) substringWithRange:NSMakeRange(2, [NSStringFromClass([self class]) length] - 7)];
}

#pragma mark - AppDelegate access functions

+ (NSManagedObjectContext*)managedObjectContext
{
    return [[self dataModel] currentObjectContext];
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

- (NSArray*)getFromIDSortKeys   {   return @[ @{ @"field": @"id", @"ascending": @YES } ];   }
- (NSArray*)getAllSortKeys      {   return @[ @{ @"field": @"id", @"ascending": @YES } ];   }

#pragma mark - watch management

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
{
    DNModelWatchKVOObject*  watch   = [[DNModelWatchKVOObject alloc] initWithModel:self
                                                                         andObject:object
                                                                     andAttributes:nil];
    
    watch.name   = [NSString stringWithFormat:@"%@.%@:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), NSStringFromClass([object class])];
    
    return watch;
}

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                     andAttributes:(NSArray*)attributes
{
    DNModelWatchKVOObject*  watch   = [[DNModelWatchKVOObject alloc] initWithModel:self
                                                                         andObject:object
                                                                     andAttributes:attributes];

    watch.name   = [NSString stringWithFormat:@"%@.%@:%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), NSStringFromClass([object class])];
    
    return watch;
}

- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
{
    DNModelWatchKVOObjects*    watch   = [[DNModelWatchKVOObjects alloc] initWithModel:self
                                                                            andObjects:objects
                                                                         andAttributes:nil];
    
    watch.name   = [NSString stringWithFormat:@"%@.%@:%@ (%lu objects)", NSStringFromClass(self.class), NSStringFromSelector(_cmd), NSStringFromClass([[objects firstObject] class]), (unsigned long)[objects count]];
    
    return watch;
}

- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                       andAttributes:(NSArray*)attributes
{
    DNModelWatchKVOObjects*    watch   = [[DNModelWatchKVOObjects alloc] initWithModel:self
                                                                            andObjects:objects
                                                                         andAttributes:attributes];

    watch.name   = [NSString stringWithFormat:@"%@.%@:%@ (%lu objects)", NSStringFromClass(self.class), NSStringFromSelector(_cmd), NSStringFromClass([[objects firstObject] class]), (unsigned long)[objects count]];
    
    return watch;
}

- (BOOL)checkWatch:(DNModelWatch*)watch
{
    return [watches containsObject:watch];
}

- (void)retainWatch:(DNModelWatch*)watch
{
    [[self class] addGlobalWatch:watch];
    [watches addObject:watch];
}

- (void)releaseWatch:(DNModelWatch*)watch
{
    [watches removeObject:watch];
    [[self class] removeGlobalWatch:watch];
}

#pragma mark - getWithFetch

- (NSFetchRequest*)getFetchRequestWithSortKeys:(NSArray*)sortKeys
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[[self class] entityName]];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to create fetchRequest");
        return nil;
    }

    NSMutableArray* sortDescriptors = [NSMutableArray array];

    [sortKeys enumerateObjectsUsingBlock:
     ^(NSDictionary* sortDict, NSUInteger idx, BOOL* stop)
     {
         NSString*  sortKey         = sortDict[@"field"];
         BOOL       sortAscending   = [sortDict[@"ascending"] boolValue];
         if (([sortKey length] > 0))
         {
             [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:sortAscending]];
         }
     }];
    if ([sortDescriptors count] > 0)
    {
        [fetchRequest setSortDescriptors:sortDescriptors];
    }

    fetchRequest.fetchBatchSize = 20;
    
    return fetchRequest;
}

- (id)getOneWithFetch:(NSFetchRequest*)fetchRequest
{
    [fetchRequest setFetchLimit:1];

    NSArray*    resultArray = [self getAllWithFetch:fetchRequest];
    if ([resultArray count] == 0)
    {
        return nil;
    }

    return resultArray[0];
}

- (NSArray*)getAllWithFetch:(NSFetchRequest*)fetchRequest
{
    __block NSArray*    resultArray;
    __block NSThread*   createdThread;

    [self performBlockAndWait:
     ^(NSManagedObjectContext* context)
     {
         @try
         {
             createdThread  = [NSThread currentThread];

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

    //DLog(LL_Error, LD_CoreData, @"Trace Point");
    if (resultArray && (![createdThread isEqual:[NSThread currentThread]]))
    {
        NSMutableArray* finalArray  = [NSMutableArray array];

        [resultArray enumerateObjectsUsingBlock:
         ^(DNManagedObject* obj, NSUInteger idx, BOOL* stop)
         {
             [finalArray addObject:[obj objectInContext:[[self class] managedObjectContext]]];
         }];

        return finalArray;
    }
    
    return resultArray;
}

#pragma mark - getFromID/watchFromID

- (id)getFromID:(id)idValue
{
    NSFetchRequest* fetchRequest    = [self getFromID_FetchRequest:idValue];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }

    return [self getOneWithFetch:fetchRequest];
}

- (id)getAllFromID:(id)idValue
{
    NSFetchRequest* fetchRequest    = [self getFromID_FetchRequest:idValue];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    return [self getAllWithFetch:fetchRequest];
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
    NSArray*        sortKeys        = [self getFromIDSortKeys];
    NSFetchRequest* fetchRequest    = [self getFetchRequestWithSortKeys:sortKeys];

    NSPredicate*    predicate   = [self getFromID_FetchRequestPredicate:idValue];
    if (predicate)
    {
        [fetchRequest setPredicate:predicate];
    }
    
    return fetchRequest;
}

#pragma mark - getFromDictionary/watchFromDictionary

- (id)getFromDictionary:(NSDictionary*)dict
{
    NSFetchRequest* fetchRequest    = [self getFromDictionary_FetchRequest:dict];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }

    return [self getOneWithFetch:fetchRequest];
}

- (DNModelWatchObject*)watchFromDictionary:(NSDictionary*)dict
{
    NSFetchRequest* fetchRequest    = [self getFromDictionary_FetchRequest:dict];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }

    return [DNModelWatchFetchedObject watchWithModel:self andFetch:fetchRequest];
}

- (NSPredicate*)getFromDictionary_FetchRequestPredicate:(NSDictionary*)dict
{
    id  idValue     = dict[@"id"];

    return [NSPredicate predicateWithFormat:@"id == %@", idValue];
}

- (NSFetchRequest*)getFromDictionary_FetchRequest:(NSDictionary*)dict
{
    NSArray*        sortKeys        = [self getFromIDSortKeys];
    NSFetchRequest* fetchRequest    = [self getFetchRequestWithSortKeys:sortKeys];
    
    NSPredicate*    predicate   = [self getFromDictionary_FetchRequestPredicate:dict];
    if (predicate)
    {
        [fetchRequest setPredicate:predicate];
    }

    return fetchRequest;
}

#pragma mark - getAll/watchAll

- (NSArray*)getAll
{
    return [self getAllOffset:0 count:0];
}

- (NSArray*)getAllOffset:(NSUInteger)offset
                   count:(NSUInteger)count
{
    NSFetchRequest* fetchRequest    = [self getAll_FetchRequestOffset:offset count:count];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }

    return [self getAllWithFetch:fetchRequest];
}

- (DNModelWatchObjects*)watchAll
{
    return [self watchAllWithCollectionView:nil offset:0 count:0];
}

- (DNModelWatchObjects*)watchAllOffset:(NSUInteger)offset
                                 count:(NSUInteger)count
{
    return [self watchAllWithCollectionView:nil offset:offset count:count];
}

- (DNModelWatchFetchedObjects*)watchAllWithCollectionView:(DNCollectionView*)collectionView
                                                   offset:(NSUInteger)offset
                                                    count:(NSUInteger)count
{
    NSFetchRequest* fetchRequest    = [self getAll_FetchRequestOffset:offset count:count];
    if (fetchRequest == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Unable to get fetchRequest");
        return nil;
    }
    
    return [DNModelWatchFetchedObjects watchWithModel:self andFetch:fetchRequest andCollectionView:collectionView];
}

- (NSFetchRequest*)getAll_FetchRequestOffset:(NSUInteger)offset
                                       count:(NSUInteger)count
{
    NSArray*        sortKeys        = [self getAllSortKeys];
    NSFetchRequest* fetchRequest    = [self getFetchRequestWithSortKeys:sortKeys];

    return fetchRequest;
}

#pragma mark - deleteAll

- (void)deleteAllWithCompletion:(DNModelCompletionHandlerBlock)handler;
{
    [self performBlock:
     ^(NSManagedObjectContext* context)
     {
         [[self getAll] enumerateObjectsUsingBlock:
          ^(DNManagedObject* object, NSUInteger idx, BOOL* stop)
          {
              [object deleteWithNoSave];
          }];

         [context processPendingChanges];

         [self saveContext];

         if (handler != nil)
         {
             handler();
         }
     }];
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
