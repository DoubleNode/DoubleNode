//
//  DNDataModel.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DNDataModel : NSObject

@property (nonatomic, strong)   NSManagedObjectContext* tempInMemoryObjectContext;

@property (strong, nonatomic, readonly)   NSManagedObjectContext*         mainObjectContext;
@property (strong, nonatomic, readonly)   NSManagedObjectContext*         concurrentObjectContext;
@property (strong, nonatomic, readonly)   NSManagedObjectContext*         tempMainObjectContext;

@property (strong, nonatomic, readonly)   NSManagedObjectModel*           managedObjectModel;
@property (strong, nonatomic, readonly)   NSPersistentStoreCoordinator*   persistentStoreCoordinator;
@property (strong, nonatomic, readonly)   NSPersistentStore*              persistentStore;

@property (strong, nonatomic)   NSString*   persistentStorePrefix;

@property (assign, atomic)      BOOL        useIncrementalStore;

+ (id)dataModel;
+ (NSString*)dataModelName;

- (id)init;

- (NSString*)storeType;
- (NSURL*)getPersistentStoreURL;

- (void)deletePersistentStore;
- (void)saveContext;

- (NSManagedObjectContext*)createNewManagedObjectContext;

@end
