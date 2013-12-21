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

@property (strong, nonatomic)   NSManagedObjectContext*         managedObjectContext;
@property (strong, nonatomic)   NSManagedObjectModel*           managedObjectModel;
@property (strong, nonatomic)   NSPersistentStoreCoordinator*   persistentStoreCoordinator;
@property (strong, nonatomic)   NSPersistentStore*              persistentStore;

@property (strong, nonatomic)   NSString*   persistentStorePrefix;

@property (assign, atomic)      BOOL        useIncrementalStore;

+ (id)dataModel;
+ (NSString*)dataModelName;

- (id)init;

- (NSString*)storeType;
- (NSURL*)getPersistentStoreURL;

- (void)deletePersistentStore;
- (void)saveContext;

- (NSManagedObjectContext*)managedObjectContext;
- (NSManagedObjectModel*)managedObjectModel;
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator;
- (NSPersistentStore*)persistentStore;

@end
