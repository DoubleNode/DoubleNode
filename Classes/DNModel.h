//
//  DNModel.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNUtilities.h"

#import "DNManagedObject.h"
#import "DNModelWatchFetchedObject.h"
#import "DNModelWatchFetchedObjects.h"

typedef void(^DNModelCompletionHandlerBlock)();

@class DNCollectionView;

@interface DNModel : NSObject

+ (id)dataModel;
+ (Class)dataModelClass;
+ (NSString*)dataModelName;
+ (NSString*)entityName;

#pragma mark - AppDelegate access functions

+ (NSArray*)globalWatchesArray;

+ (NSManagedObjectContext*)managedObjectContext;
+ (void)saveContext;

+ (instancetype)model;

- (id)init;

- (void)saveContext;

- (NSArray*)getFromIDSortKeys;
- (NSArray*)getAllSortKeys;

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object;
- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                     andAttributes:(NSArray*)attributes;

- (DNModelWatchObjects*)watchObjects:(NSArray*)objects;
- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                       andAttributes:(NSArray*)attributes;

- (BOOL)checkWatch:(DNModelWatch*)watch;
- (void)retainWatch:(DNModelWatch*)watch;
- (void)releaseWatch:(DNModelWatch*)watch;

- (NSFetchRequest*)getFetchRequestWithSortKeys:(NSArray*)sortKeys;
- (id)getOneWithFetch:(NSFetchRequest*)fetchRequest;
- (NSArray*)getAllWithFetch:(NSFetchRequest*)fetchRequest;

- (id)getFromID:(id)idValue;
- (id)getAllFromID:(id)idValue;
- (DNModelWatchObject*)watchFromID:(id)idValue;
- (NSPredicate*)getFromID_FetchRequestPredicate:(id)idValue;
- (NSFetchRequest*)getFromID_FetchRequest:(id)idValue;

- (id)getFromDictionary:(NSDictionary*)dict;
- (DNModelWatchObject*)watchFromDictionary:(NSDictionary*)dict;
- (NSPredicate*)getFromDictionary_FetchRequestPredicate:(NSDictionary*)dict;
- (NSFetchRequest*)getFromDictionary_FetchRequest:(NSDictionary*)dict;

- (NSArray*)getAll;
- (NSArray*)getAllOffset:(NSUInteger)offset
                   count:(NSUInteger)count;

- (DNModelWatchObjects*)watchAll;
- (DNModelWatchObjects*)watchAllOffset:(NSUInteger)offset
                                 count:(NSUInteger)count;
- (DNModelWatchObjects*)watchAllWithCollectionView:(DNCollectionView*)collectionView
                                            offset:(NSUInteger)offset
                                             count:(NSUInteger)count;

- (NSFetchRequest*)getAll_FetchRequestOffset:(NSUInteger)offset
                                       count:(NSUInteger)count;

- (void)deleteAllWithCompletion:(DNModelCompletionHandlerBlock)handler;

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext* context))block;
- (void)performBlock:(void (^)(NSManagedObjectContext* context))block;

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext* context))block;
- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext* context))block;

@end
