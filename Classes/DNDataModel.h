//
//  DNDataModel.h
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

@interface DNDataModel : NSObject

@property (nonatomic, strong)   NSManagedObjectContext* tempInMemoryObjectContext;

@property (strong, nonatomic, readonly)   NSMutableArray*                   currentObjectContexts;

@property (strong, nonatomic, readonly)   NSManagedObjectContext*           mainObjectContext;
@property (strong, nonatomic, readonly)   NSManagedObjectContext*           concurrentObjectContext;
@property (strong, nonatomic, readonly)   NSManagedObjectContext*           tempMainObjectContext;

@property (strong, nonatomic, readonly)   NSManagedObjectModel*             managedObjectModel;
@property (strong, nonatomic, readonly)   NSPersistentStoreCoordinator*     persistentStoreCoordinator;
@property (strong, nonatomic, readonly)   NSPersistentStore*                persistentStore;

@property (strong, nonatomic)   NSString*   persistentStorePrefix;

@property (assign, atomic)      BOOL        resetOnInitialization;

+ (id)dataModel;
+ (NSString*)dataModelName;

- (id)init;

- (NSString*)storeType;
- (NSURL*)getPersistentStoreURL;

- (NSPersistentStore*)persistentStoreWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)storeCoordinator;

- (void)deletePersistentStore;
- (void)saveContext;

- (NSManagedObjectContext*)createNewManagedObjectContext;
- (NSManagedObjectContext*)concurrentObjectContext;

- (void)createContextForCurrentThreadPerformBlock:(BOOL (^)(NSManagedObjectContext* context))block;
- (void)createContextForCurrentThreadPerformBlockAndWait:(BOOL (^)(NSManagedObjectContext* context))block;

- (NSManagedObjectContext*)createContextForCurrentThread;
- (void)assignContextToCurrentThread:(NSManagedObjectContext*)context;
- (void)removeContextFromCurrentThread:(NSManagedObjectContext*)context;
- (void)saveAndRemoveContextFromCurrentThread:(NSManagedObjectContext*)context;
- (NSManagedObjectContext*)currentObjectContext;

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext*))block;
- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext*))block;

@end
