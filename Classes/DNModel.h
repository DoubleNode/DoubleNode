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

@interface DNModel : NSObject

+ (id)dataModel;
+ (Class)dataModelClass;
+ (NSString*)dataModelName;
+ (NSString*)entityName;

#pragma mark - AppDelegate access functions

+ (NSManagedObjectContext*)managedObjectContext;
+ (void)saveContext;

+ (instancetype)model;

- (id)init;

- (void)saveContext;

- (NSPredicate*)getFromID_FetchRequestPredicate:(id)idValue;

- (NSArray*)getFromIDSortKeys;
- (NSArray*)getAllSortKeys;

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                         didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;
- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                     andAttributes:(NSArray*)attributes
                         didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;
- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;
- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                       andAttributes:(NSArray*)attributes
                           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (BOOL)checkWatch:(DNModelWatch*)watch;
- (void)retainWatch:(DNModelWatch*)watch;
- (void)releaseWatch:(DNModelWatch*)watch;

- (id)getFromID:(id)idValue;
- (DNModelWatchObject*)watchFromID:(id)idValue;

- (id)getFromDictionary:(NSDictionary*)dict;
- (DNModelWatchObject*)watchFromDictionary:(NSDictionary*)dict;

- (NSArray*)getAll;
- (DNModelWatchObjects*)watchAll;

- (void)deleteAllWithCompletion:(DNModelCompletionHandlerBlock)handler;

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext* context))block;
- (void)performBlock:(void (^)(NSManagedObjectContext* context))block;

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext* context))block;
- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext* context))block;

@end
