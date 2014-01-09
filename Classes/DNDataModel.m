//
//  DNDataModel.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNDataModel.h"

#import "AFIncrementalStore.h"
#import "DNUtilities.h"

@interface DNDataModel ()
{
}

@end

@implementation DNDataModel

@synthesize managedObjectContext        = _managedObjectContext;
@synthesize managedObjectModel          = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;
@synthesize persistentStore             = _persistentStore;

+ (id)dataModel
{
    DLog(LL_Debug, LD_CoreData, @"Should NOT be here!");

    NSException*    exception = [NSException exceptionWithName:@"DNDatalModel Exception"
                                                        reason:@"dataModel class MUST be overridden!"
                                                      userInfo:nil];
    @throw exception;
}

+ (NSString*)dataModelName
{
    if ([self class] == [DNDataModel class])
    {
        DLog(LL_Debug, LD_CoreData, @"Should NOT be here!");

        NSException*    exception = [NSException exceptionWithName:@"DNDatalModel Exception"
                                                            reason:@"dataModel class MUST be overridden!"
                                                          userInfo:nil];
        @throw exception;
    }

    // Assign DataModel class name format of: CD{DataModelName}DataModel
    return [NSStringFromClass([self class]) substringWithRange:NSMakeRange(2, [NSStringFromClass([self class]) length] - 11)];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.persistentStorePrefix  = @"";
        self.useIncrementalStore    = NO;
    }

    return self;
}

- (NSString*)storeType
{
    return NSSQLiteStoreType;
}

- (NSURL*)getPersistentStoreURL
{
    NSString*   appDocsDir  = [DNUtilities applicationDocumentsDirectory];
    NSString*   storePath   = [appDocsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.sqlite", self.persistentStorePrefix, [[self class] dataModelName]]];

    return [NSURL fileURLWithPath:storePath];
}

- (void)deletePersistentStore
{
    _managedObjectContext       = nil;
    _managedObjectModel         = nil;
    _persistentStoreCoordinator = nil;
    _persistentStore            = nil;

    NSURL*  storeUrl    = [self getPersistentStoreURL];

    DLog(LL_Error, LD_CoreData, @"CoreData store deleted (%@)", storeUrl);
    [[NSFileManager defaultManager] removeItemAtPath:[storeUrl absoluteString] error:nil];
}

- (void)saveContext
{
    NSManagedObjectContext*     moc = [self managedObjectContext];
    if (moc != nil)
    {
        NSError*    error = nil;

        if ([moc hasChanges] && ![moc save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DLog(LL_Critical, LD_CoreData, @"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

//Explicitly write Core Data accessors
- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext)
    {
        return _managedObjectContext;
    }

    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    if (_managedObjectContext)
    {
        NSPersistentStoreCoordinator*   coordinator = [self persistentStoreCoordinator];
        if (coordinator)
        {
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }

    NSString*   dataModelName   = [[self class] dataModelName];
    NSURL*      modelURL        = [[NSBundle mainBundle] URLForResource:dataModelName withExtension:@"momd"];

    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
    {
        return _persistentStoreCoordinator;
    }

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    // Create persistentStore
    NSPersistentStore*  pst = [self persistentStore];
    if (pst == nil)
    {
        DLog(LL_Error, LD_CoreData, @"Error creating persistentStore");
    }

    return _persistentStoreCoordinator;
}

- (NSPersistentStore*)persistentStore
{
    if (_persistentStore)
    {
        return _persistentStore;
    }

    NSError*    error       = nil;
    NSURL*      storeUrl    = [self getPersistentStoreURL];

    NSDictionary*   options = @{
                                NSInferMappingModelAutomaticallyOption : @(YES),
                                NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                };

    if ([self useIncrementalStore] == YES)
    {
        NSString*   incrmentalStoreClass    = [NSString stringWithFormat:@"%@IncrementalStore", [[self class] dataModelName]];

        AFIncrementalStore* ist = (AFIncrementalStore*)[[self persistentStoreCoordinator] addPersistentStoreWithType:[NSClassFromString(incrmentalStoreClass) type]
                                                                                                       configuration:nil
                                                                                                                 URL:nil
                                                                                                             options:nil
                                                                                                               error:&error];
        if (ist != nil)
        {
            _persistentStore = [ist.backingPersistentStoreCoordinator addPersistentStoreWithType:[self storeType]
                                                                                   configuration:nil
                                                                                             URL:storeUrl
                                                                                         options:options
                                                                                           error:&error];
        }
    }
    else
    {
        _persistentStore = [[self persistentStoreCoordinator] addPersistentStoreWithType:[self storeType]
                                                                           configuration:nil
                                                                                     URL:storeUrl
                                                                                 options:options
                                                                                   error:&error];
        
        DLog(LL_Error, LD_CoreData, @"CoreData store exists:%@ (%@)", ([[NSFileManager defaultManager] fileExistsAtPath:[storeUrl absoluteString]] ? @"YES" : @"NO"), storeUrl);
    }
    if (_persistentStore == nil)
    {
        // Check if CoreData model inconsistency error
        if ((error.domain == NSCocoaErrorDomain) && ((error.code == 134130) || (error.code == 134140)))
        {
            DLog(LL_Error, LD_CoreData, @"CoreData Model Inconsistency Error: %@, %@", error, [error userInfo]);
            //pst = nil;

            [self deletePersistentStore];
            return nil;
        }

        DLog(LL_Critical, LD_CoreData, @"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStore;
}

@end
