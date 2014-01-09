//
//  DNModel.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
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

//+ (id<DNApplicationProtocol>)appDelegate;
+ (NSManagedObjectContext*)managedObjectContext;
+ (NSManagedObjectModel*)managedObjectModel;
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
- (DNModelWatchObject*)getFromID:(id)idValue didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;

- (id)getAll;
- (DNModelWatchObjects*)getAllDidChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (void)deleteAllWithCompletion:(DNModelCompletionHandlerBlock)handler;

@end
