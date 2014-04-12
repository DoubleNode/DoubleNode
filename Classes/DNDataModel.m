//
//  DNDataModel.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNDataModel.h"

#import "NSManagedObjectContext+description.h"

#import "DNUtilities.h"

#define SAVE_TO_DISK_TIME_INTERVAL 1.0f

@interface DNDataModel ()
{
}

@property (strong, nonatomic) NSManagedObjectContext*   privateWriterContext;   // tied to the persistent store coordinator

- (void)contextObjectsDidChange:(NSNotification*)notification;
- (void)saveToDisk:(NSNotification*)notification;

@end

@implementation DNDataModel

@synthesize tempInMemoryObjectContext   = _tempInMemoryObjectContext;

@synthesize mainObjectContext           = _mainObjectContext;
@synthesize concurrentObjectContext     = _concurrentObjectContext;
@synthesize tempMainObjectContext       = _tempMainObjectContext;

@synthesize managedObjectModel          = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;
@synthesize persistentStore             = _persistentStore;

+ (id)dataModel
{
    DLog(LL_Debug, LD_CoreData, @"Should NOT be here!");

    NSException*    exception = [NSException exceptionWithName:@"DNDataModel Exception"
                                                        reason:@"dataModel class MUST be overridden!"
                                                      userInfo:nil];
    @throw exception;
}

+ (NSString*)dataModelName
{
    if ([self class] == [DNDataModel class])
    {
        DLog(LL_Debug, LD_CoreData, @"Should NOT be here!");

        NSException*    exception = [NSException exceptionWithName:@"DNDataModel Exception"
                                                            reason:@"dataModel class MUST be overridden!"
                                                          userInfo:nil];
        @throw exception;
    }

    // Assign DataModel class name format of: CD{DataModelName}DataModel
    return [NSStringFromClass([self class]) substringWithRange:NSMakeRange(2, [NSStringFromClass([self class]) length] - 11)];
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(saveToDisk:)
                                               object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.persistentStorePrefix  = @"";
        self.resetOnInitialization  = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveToDisk:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveToDisk:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
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
    [NSFetchedResultsController deleteCacheWithName:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(saveToDisk:)
                                               object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:self.mainObjectContext];

    NSURL*  storeUrl    = [self getPersistentStoreURL];
    DLog(LL_Error, LD_CoreData, @"CoreData store exists:%@ (%@)", ([[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]] ? @"YES" : @"NO"), storeUrl);

    NSError*    error   = nil;

    @try
    {
        [_mainObjectContext reset];
        [_tempInMemoryObjectContext reset];
        [_concurrentObjectContext reset];
        [_tempMainObjectContext reset];
        [_privateWriterContext reset];

        for (NSPersistentStore* store in [self persistentStoreCoordinator].persistentStores)
        {
            if (![[self persistentStoreCoordinator] removePersistentStore:store error:&error])
            {
                DLog(LL_Error, LD_CoreData, @"Error deleting CoreData persistent store: %@", error);
            }
        }

        if (![[NSFileManager defaultManager] removeItemAtPath:[storeUrl path] error:&error])
        {
            DLog(LL_Error, LD_CoreData, @"Error deleting CoreData store file (%@): %@", storeUrl, error);
        }
    }
    @catch (NSException* exception)
    {
        DLog(LL_Error, LD_CoreData, @"Error deleting CoreData persistent store: %@", error);
    }

    _persistentStoreCoordinator = nil;
    _persistentStore            = nil;
    _managedObjectModel         = nil;

    _mainObjectContext          = nil;
    _tempInMemoryObjectContext  = nil;
    _concurrentObjectContext    = nil;
    _tempMainObjectContext      = nil;
    _privateWriterContext       = nil;

    DLog(LL_Error, LD_CoreData, @"CoreData store deleted (%@)", storeUrl);
}

- (void)saveContext
{
    [self performWithContext:self.mainObjectContext
                       block:^(NSManagedObjectContext* context)
     {
         NSError*    error = nil;
         
         if ([context hasChanges] && ![context save:&error])
         {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             DLog(LL_Critical, LD_CoreData, @"Unresolved error %@, %@", error, [error userInfo]);
             abort();
         }
     }];
}

- (NSManagedObjectContext*)createNewManagedObjectContext
{
    NSManagedObjectContext* retValue = nil;

    NSPersistentStoreCoordinator*   coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        retValue = [[NSManagedObjectContext alloc] init];
        [retValue setPersistentStoreCoordinator:coordinator];
    }

    return retValue;
}

#pragma mark - Core Data accessors

- (NSManagedObjectContext*)tempInMemoryObjectContext
{
    if (!_tempInMemoryObjectContext)
    {
        NSMutableDictionary*    options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

        NSError*    error = nil;

        NSPersistentStoreCoordinator*   persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                 configuration:nil
                                                           URL:[NSURL URLWithString:@"tempInMemoryStore"]
                                                       options:options
                                                         error:&error];

        _tempInMemoryObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        if (_tempInMemoryObjectContext)
        {
            [_tempInMemoryObjectContext.userInfo setObject:[NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)] forKey:@"mocName"];
            [_tempInMemoryObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
            [_tempInMemoryObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
        }
    }

    return _tempInMemoryObjectContext;
}

- (NSManagedObjectContext*)mainObjectContext
{
    if (_mainObjectContext)
    {
        return _mainObjectContext;
    }

    _mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    if (_mainObjectContext)
    {
        [_mainObjectContext.userInfo setObject:[NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)] forKey:@"mocName"];
        [_mainObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
        [_mainObjectContext setStalenessInterval:0];

        [self performWithContext:_mainObjectContext
                    blockAndWait:^(NSManagedObjectContext* context)
         {
             [context setParentContext:self.privateWriterContext];
         }];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextObjectsDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:_mainObjectContext];
    }

    return _mainObjectContext;
}

- (NSManagedObjectContext*)concurrentObjectContext
{
    NSManagedObjectContext* concurrentObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (concurrentObjectContext)
    {
        [concurrentObjectContext.userInfo setObject:[NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)] forKey:@"mocName"];
        [concurrentObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
        [concurrentObjectContext setParentContext:self.mainObjectContext];
    }

    return concurrentObjectContext;
}

- (NSManagedObjectContext*)tempMainObjectContext
{
    NSManagedObjectContext* tempMainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    if (tempMainObjectContext)
    {
        [tempMainObjectContext.userInfo setObject:[NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)] forKey:@"mocName"];
        [tempMainObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
        [tempMainObjectContext setParentContext:self.mainObjectContext];
    }

    return tempMainObjectContext;
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

- (NSPersistentStore*)persistentStoreWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)storeCoordinator
{
    NSPersistentStore*  retval;

    NSError*    error       = nil;
    NSURL*      storeUrl    = [self getPersistentStoreURL];

    if ([self resetOnInitialization] == YES)
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:[storeUrl path] error:&error])
        {
            DLog(LL_Error, LD_CoreData, @"Error deleting CoreData store file (%@): %@", storeUrl, error);
        }
    }

    NSDictionary*   options = @{
                                NSInferMappingModelAutomaticallyOption : @(YES),
                                NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                };

    for (int retry = 0; retry < 2; retry++)
    {
        retval = [storeCoordinator addPersistentStoreWithType:[self storeType]
                                                configuration:nil
                                                          URL:storeUrl
                                                      options:options
                                                        error:&error];
        // If Successful...
        if (retval)
        {
            DLog(LL_Error, LD_CoreData, @"CoreData store exists:%@ (%@)", ([[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]] ? @"YES" : @"NO"), storeUrl);
            break;
        }

        // ...else If Error...
        if (![[NSFileManager defaultManager] removeItemAtPath:[storeUrl path] error:&error])
        {
            DLog(LL_Error, LD_CoreData, @"Error deleting CoreData store file (%@): %@", storeUrl, error);
        }

        // Check if CoreData model inconsistency error
        //if ((error.domain == NSCocoaErrorDomain) && ((error.code == 134130) || (error.code == 134140)))
        //{
        //    DLog(LL_Error, LD_CoreData, @"CoreData Model Inconsistency Error: %@, %@", error, [error userInfo]);

        //    [self deletePersistentStore];
        //    return nil;
        //}

        DLog(LL_Error, LD_CoreData, @"CoreData RETRY create persistentStore");
    }
    if (retval == nil)
    {
        DLog(LL_Critical, LD_CoreData, @"Unresolved error %@, %@", error, [error userInfo]);
    }

    return retval;
}

- (NSPersistentStore*)persistentStore
{
    if (_persistentStore)
    {
        return _persistentStore;
    }

    _persistentStore = [self persistentStoreWithPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    if (_persistentStore == nil)
    {
        DLog(LL_Critical, LD_CoreData, @"Error creating persistent store");
        abort();
    }

    return _persistentStore;
}

#pragma mark - Private methods

- (NSManagedObjectContext*)privateWriterContext
{
    if (_privateWriterContext)
    {
        return _privateWriterContext;
    }

    _privateWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (_privateWriterContext)
    {
        [_privateWriterContext.userInfo setObject:[NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)] forKey:@"mocName"];
        [_privateWriterContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];

        [self performWithContext:_privateWriterContext
                    blockAndWait:^(NSManagedObjectContext* context)
         {
             [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
         }];
    }

    return _privateWriterContext;
}

- (void)contextDidSave:(NSNotification*)notification
{
    NSManagedObjectContext* notificationContext = [notification object];
    if (self.mainObjectContext.persistentStoreCoordinator != notificationContext.persistentStoreCoordinator)
    {
        return;
    }

    if (notificationContext == self.mainObjectContext)
    {
        return;
    }

    [self.mainObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

- (void)contextObjectsDidChange:(NSNotification*)notification
{
    NSManagedObjectContext* notificationContext = [notification object];

    if (notificationContext != self.mainObjectContext)
    {
        return;
    }

    if (self.mainObjectContext.persistentStoreCoordinator != notificationContext.persistentStoreCoordinator)
    {
        return;
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveToDisk:) object:nil];

    [self performSelector:@selector(saveToDisk:) withObject:nil afterDelay:SAVE_TO_DISK_TIME_INTERVAL];
}

- (void)saveToDisk:(NSNotification*)notification
{
    NSManagedObjectContext* savingContext = self.mainObjectContext;

    [self performWithContext:self.mainObjectContext
                blockAndWait:^(NSManagedObjectContext* context)
     {
         NSError*    error = nil;
         
         if (![self.mainObjectContext save:&error])
         {
             DLog(LL_Error, LD_CoreData, @"ERROR saving main context: %@", [error localizedDescription]);
             NSArray*   detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
             if ((detailedErrors != nil) && ([detailedErrors count] > 0))
             {
                 for (NSError* detailedError in detailedErrors)
                 {
                     DLog(LL_Error, LD_CoreData, @"  DetailedError: %@", [detailedError userInfo]);
                 }
             }
             else
             {
                 DLog(LL_Error, LD_CoreData, @"  %@", [error userInfo]);
             }
         }
     }];

    if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"] == YES)
    {
        DLog(LL_Debug, LD_CoreData, @"CDTableDataModel");
    }

    DLog(LL_Debug, LD_CoreData, @"Main context saved to disk");

    if (![savingContext.parentContext hasChanges])
    {
        return;
    }

    void (^saveToDiskBlock)() = ^
    {
        [self performWithContext:savingContext.parentContext
                           block:^(NSManagedObjectContext* context)
         {
             NSError*    error = nil;

             if (![savingContext.parentContext save:&error])
             {
                 DLog(LL_Error, LD_CoreData, @"ERROR saving writer context: %@", [error localizedDescription]);
             }

             DLog(LL_Debug, LD_CoreData, @"Writer context saved to disk");
         }];
    };
    
    if (notification)
    {
        [savingContext performBlockAndWait:saveToDiskBlock];
    }
    else
    {
        [savingContext performBlock:saveToDiskBlock];
    }
}

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext*))block
{
    if ((context == self.mainObjectContext) && ([NSThread isMainThread]))
    {
        block(context);
    }
    else
    {
        [context performBlockAndWait:^{
            block(context);
        }];
    }
}

- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext*))block
{
    if ((context == self.mainObjectContext) && ([NSThread isMainThread]))
    {
        block(context);
    }
    else
    {
        [context performBlock:^{
            block(context);
        }];
    }
}

@end
