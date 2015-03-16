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

#define SAVE_TO_DISK_TIME_INTERVAL 3.0f

@interface DNDataModel ()
{
}

@property (strong, nonatomic) NSManagedObjectContext*   privateWriterContext;   // tied to the persistent store coordinator

@end

@implementation DNDataModel

@synthesize tempInMemoryObjectContext   = _tempInMemoryObjectContext;

@synthesize currentObjectContexts       = _currentObjectContexts;
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
    //DOLog(LL_Debug, LD_General, @"deletePersistentStore - start");
    [NSFetchedResultsController deleteCacheWithName:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(saveToDisk:)
                                               object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:self.mainObjectContext];

    NSURL*  storeUrl    = [self getPersistentStoreURL];
    //DOLog(LL_Debug, LD_General, @"CoreData store exists:%@ (%@)", ([[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]] ? @"YES" : @"NO"), storeUrl);

    NSError*    error   = nil;

    @try
    {
        @synchronized(_currentObjectContexts)
        {
            [_currentObjectContexts enumerateObjectsUsingBlock:
             ^(NSDictionary* threadContext, NSUInteger idx, BOOL* stop)
             {
                 NSArray*   contexts    = threadContext[@"contexts"];
                 [contexts enumerateObjectsUsingBlock:
                  ^(NSManagedObjectContext* context, NSUInteger idx, BOOL *stop)
                  {
                      [DNUtilities runOnBackgroundThread:
                       ^()
                      {
                          [context performBlockAndWait:
                           ^()
                           {
                               [context reset];
                           }];
                      }];
                  }];
             }];
            
            [_currentObjectContexts removeAllObjects];
        }

        [_mainObjectContext reset];
        [_tempInMemoryObjectContext reset];
        [_concurrentObjectContext reset];
        [_tempMainObjectContext reset];
        
        [_privateWriterContext performBlockAndWait:
         ^()
         {
             [_privateWriterContext reset];
         }];

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

    //DOLog(LL_Debug, LD_General, @"CoreData store exists:%@ (%@)", ([[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]] ? @"YES" : @"NO"), storeUrl);

    _persistentStoreCoordinator = nil;
    _persistentStore            = nil;
    _managedObjectModel         = nil;

    [_currentObjectContexts removeAllObjects];
    _currentObjectContexts      = nil;

    _mainObjectContext          = nil;
    _tempInMemoryObjectContext  = nil;
    _concurrentObjectContext    = nil;
    _tempMainObjectContext      = nil;
    _privateWriterContext       = nil;

    //DOLog(LL_Debug, LD_General, @"CoreData store deleted (%@)", storeUrl);
    
    //DOLog(LL_Debug, LD_General, @"deletePersistentStore - end");
}

- (void)saveContext
{
    NSManagedObjectContext* currentContext = self.currentObjectContext;
    [self performWithContext:currentContext
                       block:^(NSManagedObjectContext* context)
     {
         if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
         {
             //DOLog(LL_Debug, LD_CoreData, @"saveContext: currentContext=%@", currentContext);
         }
         if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
         {
             //DOLog(LL_Debug, LD_CoreData, @"%lu objects (ins:%lu, upd:%lu, del:%lu)", (unsigned long)[[context registeredObjects] count], (unsigned long)[[context insertedObjects] count], (unsigned long)[[context updatedObjects] count], (unsigned long)[[context deletedObjects] count]);
         }
         
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
        [retValue setStalenessInterval:0];
        
        [retValue setPersistentStoreCoordinator:coordinator];
    }

    return retValue;
}

#pragma mark - Multi-Threaded support

// Method deprecated - use new startTransactionPerformBlock: method
- (void)createContextForCurrentThreadPerformBlock:(BOOL (^)(NSManagedObjectContext* context))block
{
    [self startTransactionPerformBlock:block];
}

// Method deprecated - use new startTransactionPerformBlockAndWait: method
- (void)createContextForCurrentThreadPerformBlockAndWait:(BOOL (^)(NSManagedObjectContext* context))block
{
    [self startTransactionPerformBlockAndWait:block];
}

- (NSManagedObjectContext*)startTransaction
{
    // DME-DEBUG Problem with MainThread -- return [self concurrentObjectContext];
    return [self createContextForCurrentThread];
}

- (void)cancelTransaction:(NSManagedObjectContext*)context
{
    if (!context)
    {
        return;
    }

    [context reset];
    
    if (![NSThread isMainThread])
    {
        [self removeContextFromCurrentThread:context];
    }
}

- (void)saveTransaction:(NSManagedObjectContext*)context
{
    if (!context)
    {
        return;
    }
    
    [context save:NULL];
    
    if (![NSThread isMainThread])
    {
        [self removeContextFromCurrentThread:context];
    }
}

- (void)startTransactionPerformBlockAndWait:(BOOL (^)(NSManagedObjectContext* context))block
{
    NSManagedObjectContext* context = [self startTransaction];

    [context performBlockAndWait:
     ^()
     {
         BOOL   save;
         
         //@autoreleasepool
         {
             save = block(context);
         }
         if (!save)
         {
             [self cancelTransaction:context];
         }
         else
         {
             [self saveTransaction:context];
         }
     }];
}

- (void)startTransactionPerformBlock:(BOOL (^)(NSManagedObjectContext* context))block
{
    NSManagedObjectContext* context = [self startTransaction];
    
    [context performBlock:
     ^()
     {
         BOOL   save;
         
         //@autoreleasepool
         {
             save = block(context);
         }
         if (!save)
         {
             [self cancelTransaction:context];
         }
         else
         {
             [self saveTransaction:context];
         }
     }];
}

- (NSManagedObjectContext*)createContextForCurrentThread
{
    NSManagedObjectContext* tempContext;

    if ([NSThread isMainThread])
    {
        tempContext = [self mainObjectContext];
        [tempContext performBlockAndWait:
         ^()
         {
             [tempContext save:NULL];
         }];

        return tempContext;
    }

    tempContext = [self concurrentObjectContext];

    [self assignContextToCurrentThread:tempContext];

    return tempContext;
}

- (void)assignContextToCurrentThread:(NSManagedObjectContext*)context
{
    NSMutableDictionary*    currentThreadedObject   = [self currentThreadedObject];
    /*
    NSManagedObjectContext* currentContext  = [self currentThreadedObjectContext];
    if (currentContext)
    {
        if ([NSStringFromClass([self class]) isEqualToString:@"CDMainDataModel"])
        {
            DOLog(LL_Debug, LD_General, @"assignContextToCurrentThread: context=%@, parent=%@", context, context.parentContext);
        }
        
        DOLog(LL_Debug, LD_General, @"ssignContextToCurrentThread: removing existing context");
        [self saveAndRemoveContextFromCurrentThread:currentContext];
    }
     */

    @synchronized(_currentObjectContexts)
    {
        if (_currentObjectContexts == nil)
        {
            _currentObjectContexts = [NSMutableArray array];
        }

        [[NSThread currentThread] setName:[NSString stringWithFormat:@"DNDataModel Thread: %@", NSStringFromClass([self class])]];
        
        if (currentThreadedObject)
        {
            NSMutableArray* contexts    = [currentThreadedObject[@"contexts"] mutableCopy];
            [contexts addObject:context];
            
            currentThreadedObject[@"contexts"]   = contexts;
        }
        else
        {
            currentThreadedObject   = [@{
                                        @"thread": [NSThread currentThread],
                                        @"contexts": @[ context ]
                                        } mutableCopy];
        }

        //DOLog(LL_Debug, LD_General, @"assignContextToCurrentThread: %@", [NSThread currentThread]);
        [_currentObjectContexts addObject:currentThreadedObject];
    }
}

- (void)removeContextFromCurrentThread:(NSManagedObjectContext*)context
{
    @synchronized(_currentObjectContexts)
    {
        [_currentObjectContexts enumerateObjectsUsingBlock:
         ^(NSDictionary* threadContext, NSUInteger idx, BOOL* stop)
         {
             NSMutableArray*    contexts    = [threadContext[@"contexts"] mutableCopy];
             if ([contexts containsObject:context])
             {
                 [contexts removeObject:context];
             }
             if ([contexts count] == 0)
             {
                 //DOLog(LL_Debug, LD_General, @"removeContextFromCurrentThread: %@", threadContext);
                 [_currentObjectContexts removeObject:threadContext];

                 [[NSThread currentThread] setName:[NSString stringWithFormat:@"DONE: DNDataModel Thread: %@", NSStringFromClass([self class])]];
                 *stop = YES;
             }
         }];
    }
}

- (void)saveAndRemoveContextFromCurrentThread:(NSManagedObjectContext*)context
{
    [context performBlockAndWait:
     ^()
     {
         if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
         {
             //DOLog(LL_Debug, LD_CoreData, @"saveAndRemoveContextFromCurrentThread: context=%@", context);
         }
         
         [self saveContext:context];
         
         [self removeContextFromCurrentThread:context];
     }];
}

- (NSMutableDictionary*)currentThreadedObject
{
    __block NSMutableDictionary*    retval;
    
    @synchronized(_currentObjectContexts)
    {
        [_currentObjectContexts enumerateObjectsUsingBlock:
         ^(NSMutableDictionary* threadContext, NSUInteger idx, BOOL* stop)
         {
             NSThread*  thread  = threadContext[@"thread"];
             if ([thread isEqual:[NSThread currentThread]])
             {
                 retval = threadContext;
                 *stop  = YES;
             }
         }];
    }
    
    return retval;
}

- (NSManagedObjectContext*)currentThreadedObjectContext
{
    __block NSManagedObjectContext* retval;

    @synchronized(_currentObjectContexts)
    {
        [_currentObjectContexts enumerateObjectsUsingBlock:
         ^(NSDictionary* threadContext, NSUInteger idx, BOOL* stop)
         {
             NSThread*  thread  = threadContext[@"thread"];
             if ([thread isEqual:[NSThread currentThread]])
             {
                 retval = [threadContext[@"contexts"] lastObject];
                 *stop  = YES;
             }
         }];
    }

    return retval;
}

- (NSManagedObjectContext*)currentObjectContext
{
    NSManagedObjectContext* retval  = [self currentThreadedObjectContext];
    if (retval == nil)
    {
        if ([NSThread isMainThread])
        {
            retval = [self mainObjectContext];
        }
        else
        {
            retval = [self createContextForCurrentThread];
        }
    }

    return retval;
}

#pragma mark - Core Data accessors

- (NSManagedObjectContext*)tempInMemoryObjectContext
{
    if (!_tempInMemoryObjectContext)
    {
        NSMutableDictionary*    options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           @YES, NSMigratePersistentStoresAutomaticallyOption,
                                           @YES, NSInferMappingModelAutomaticallyOption, nil];

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
            [_tempInMemoryObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
            //[_tempInMemoryObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];

            [_tempInMemoryObjectContext setStalenessInterval:0];
            
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

    [DNUtilities runOnMainThreadWithoutDeadlocking:
     ^()
     {
         _mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
         if (_mainObjectContext)
         {
             [_mainObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
             //[_mainObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];

             [_mainObjectContext setStalenessInterval:0];
             
             [self performWithContext:_mainObjectContext
                         blockAndWait:
              ^(NSManagedObjectContext* context)
              {
                  NSString*   mocName = [NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)];
                  [context.userInfo setObject:mocName forKey:@"mocName"];

                  [context setParentContext:self.privateWriterContext];
              }];
             
             /*
              [[NSNotificationCenter defaultCenter] removeObserver:self
              name:NSManagedObjectContextDidSaveNotification
              object:nil];
              [[NSNotificationCenter defaultCenter] addObserver:self
              selector:@selector(contextDidSave:)
              name:NSManagedObjectContextDidSaveNotification
              object:nil];
              */
             
             [[NSNotificationCenter defaultCenter] removeObserver:self
                                                             name:NSManagedObjectContextObjectsDidChangeNotification
                                                           object:nil];
             [[NSNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(contextObjectsDidChange:)
                                                          name:NSManagedObjectContextObjectsDidChangeNotification
                                                        object:_mainObjectContext];
         }
     }];

    return _mainObjectContext;
}

- (NSManagedObjectContext*)concurrentObjectContext
{
    NSManagedObjectContext* concurrentObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if (concurrentObjectContext)
    {
        [concurrentObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
        //[concurrentObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];

        [concurrentObjectContext setStalenessInterval:0];

        [self performWithContext:concurrentObjectContext
                    blockAndWait:
         ^(NSManagedObjectContext* context)
         {
             NSString*   mocName = [NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)];
             [context.userInfo setObject:mocName forKey:@"mocName"];
             
             [context setParentContext:self.mainObjectContext];
         }];
    }

    return concurrentObjectContext;
}

- (NSManagedObjectContext*)tempMainObjectContext
{
    NSManagedObjectContext* tempMainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    if (tempMainObjectContext)
    {
        [tempMainObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
        //[tempMainObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
        
        [tempMainObjectContext setStalenessInterval:0];
        
        [self performWithContext:tempMainObjectContext
                    blockAndWait:
         ^(NSManagedObjectContext* context)
         {
             NSString*   mocName = [NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)];
             [context.userInfo setObject:mocName forKey:@"mocName"];
             
             [context setParentContext:self.mainObjectContext];
         }];
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
        [_privateWriterContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
        //[_privateWriterContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
        
        [_privateWriterContext setStalenessInterval:0];
        
        [self performWithContext:_privateWriterContext
                    blockAndWait:
         ^(NSManagedObjectContext* context)
         {
             NSString*   mocName = [NSString stringWithFormat:@"%@@%@", [[self class] dataModelName], NSStringFromSelector(_cmd)];
             [context.userInfo setObject:mocName forKey:@"mocName"];
             
             [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
         }];
    }

    return _privateWriterContext;
}

/*
- (void)contextDidSave:(NSNotification*)notification
{
    NSManagedObjectContext* notificationContext = [notification object];

    if (notificationContext == self.mainObjectContext)
    {
        return;
    }
    if (notificationContext.parentContext == nil)
    {
        return;
    }

    if (self.mainObjectContext.persistentStoreCoordinator != notificationContext.persistentStoreCoordinator)
    {
        return;
    }

    if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
    {
        DLog(LL_Debug, LD_CoreData, @"contextDidSave: notificationContext=%@, parent=%@", notificationContext, notificationContext.parentContext);
        DLog(LL_Debug, LD_CoreData, @"%lu objects (ins:%lu, upd:%lu, del:%lu)", (unsigned long)[[notificationContext registeredObjects] count], (unsigned long)[[notificationContext insertedObjects] count], (unsigned long)[[notificationContext updatedObjects] count], (unsigned long)[[notificationContext deletedObjects] count]);
    }
    [notificationContext.parentContext performBlock:^
     {
          NSError*   error;
          
         [notificationContext.parentContext mergeChangesFromContextDidSaveNotification:notification];
         if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
         {
             DLog(LL_Debug, LD_CoreData, @"%lu objects (ins:%lu, upd:%lu, del:%lu)", (unsigned long)[[notificationContext.parentContext registeredObjects] count], (unsigned long)[[notificationContext.parentContext insertedObjects] count], (unsigned long)[[notificationContext.parentContext updatedObjects] count], (unsigned long)[[notificationContext.parentContext deletedObjects] count]);
         }
         if (![notificationContext.parentContext save:&error])
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
}
 */

- (void)contextObjectsDidChange:(NSNotification*)notification
{
    NSManagedObjectContext* notificationContext = [notification object];
    if (notificationContext != self.mainObjectContext)
    {
        DOLog(LL_Debug, LD_General, @"*** NOT mainObjectContext (should NOT be here) [%@:%@:%d]", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
        return;
    }

    if (self.mainObjectContext.persistentStoreCoordinator != notificationContext.persistentStoreCoordinator)
    {
        DOLog(LL_Debug, LD_General, @"*** Different persistentStoreCoordinator (should NOT be here) [%@:%@:%d]", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
        return;
    }

    /*
    if ([NSStringFromClass([self class]) isEqualToString:@"CDMainDataModel"])
    {
        DOLog(LL_Debug, LD_General, @"contextObjectsDidChange: notificationContext=%@, parent=%@", notificationContext, notificationContext.parentContext);
        DOLog(LL_Debug, LD_General, @"%lu objects (ins:%lu, upd:%lu, del:%lu)", (unsigned long)[[notificationContext registeredObjects] count], (unsigned long)[[notificationContext insertedObjects] count], (unsigned long)[[notificationContext updatedObjects] count], (unsigned long)[[notificationContext deletedObjects] count]);
        DOLog(LL_Debug, LD_General, @"contextObjectsDidChange: %@", notification);
    }
    if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
    {
        DOLog(LL_Debug, LD_General, @"contextObjectsDidChange: notificationContext=%@, parent=%@", notificationContext, notificationContext.parentContext);
        DOLog(LL_Debug, LD_General, @"%lu objects (ins:%lu, upd:%lu, del:%lu)", (unsigned long)[[notificationContext registeredObjects] count], (unsigned long)[[notificationContext insertedObjects] count], (unsigned long)[[notificationContext updatedObjects] count], (unsigned long)[[notificationContext deletedObjects] count]);
        DOLog(LL_Debug, LD_General, @"contextObjectsDidChange: %@", notification);
    }
     */
    
    // DME-DEBUG
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveToDisk:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(saveToDisk:) withObject:notification afterDelay:SAVE_TO_DISK_TIME_INTERVAL];
}

- (void)saveToDisk:(NSNotification*)notification
{
    NSManagedObjectContext* notificationContext = notification.object;
    if (![self isKindOfClass:[DNDataModel class]])
    {
        return;
    }

    if (![notificationContext isKindOfClass:[NSManagedObjectContext class]])
    {
        return;
    }

    [notificationContext performBlock:
     ^()
     {
         //if ([NSStringFromClass([self class]) isEqualToString:@"CDMainDataModel"])
         //{
         //    DLog(LL_Debug, LD_CoreData, @"saveToDisk: notificationContext=%@, parent=%@", notificationContext, notificationContext.parentContext);
         //}
         if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
         {
             //DOLog(LL_Debug, LD_CoreData, @"saveToDisk: notificationContext=%@", notificationContext);
         }
         
         [self saveContext:notificationContext];
         
         if (notificationContext.parentContext)
         {
             [notificationContext.parentContext performBlock:
              ^()
              {
                  [notificationContext.parentContext mergeChangesFromContextDidSaveNotification:notification];
                  
                  //DOLog(LL_Debug, LD_General, @"saveContext: notificationContext.parentContext");
                  [self saveContext:notificationContext.parentContext];
              }];
         }
     }];
}

- (void)saveContext:(NSManagedObjectContext*)context
{
    [context performBlockAndWait:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"saveContext: %lu objects (ins:%lu, upd:%lu, del:%lu)", (unsigned long)[[context registeredObjects] count], (unsigned long)[[context insertedObjects] count], (unsigned long)[[context updatedObjects] count], (unsigned long)[[context deletedObjects] count]);
         
         /*
         if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
         {
             DOLog(LL_Debug, LD_General, @"%lu objects (ins:%lu, upd:%lu, del:%lu)", (unsigned long)[[notificationContext registeredObjects] count], (unsigned long)[[notificationContext insertedObjects] count], (unsigned long)[[notificationContext updatedObjects] count], (unsigned long)[[notificationContext deletedObjects] count]);
             
             NSArray*  objects = [notificationContext registeredObjects];
             [objects enumerateObjectsUsingBlock:
              ^(id obj, NSUInteger idx, BOOL* stop)
              {
                  NSString*    className   = NSStringFromClass([obj class]);
                  DOLog(LL_Debug, LD_General, @"obj=[%@]", className);
                  if ([className isEqualToString:@"CDOChurch"])
                  {
                      DOLog(LL_Debug, LD_General, @"obj.objectID=%@", [obj objectID]);
                      DOLog(LL_Debug, LD_General, @"obj=%@", obj);
                  }
                  if ([className isEqualToString:@"CDOFeature"])
                  {
                      DOLog(LL_Debug, LD_General, @"obj.objectID=%@", [obj objectID]);
                      DOLog(LL_Debug, LD_General, @"obj=%@", obj);
                  }
              }];
         }
         */

         if (![context hasChanges])
         {
             DOLog(LL_Debug, LD_General, @"*** NO CHANGES [%@:%@:%d]", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
             //return;

             if ([NSStringFromClass([self class]) isEqualToString:@"CDTableDataModel"])
             {
                 //DOLog(LL_Debug, LD_General, @"%lu objects (ins:%lu, upd:%lu, del:%lu)", (unsigned long)[[context registeredObjects] count], (unsigned long)[[context insertedObjects] count], (unsigned long)[[context updatedObjects] count], (unsigned long)[[context deletedObjects] count]);
                 
                 /*
                 NSArray*  objects = [context registeredObjects];
                 [objects enumerateObjectsUsingBlock:
                  ^(id obj, NSUInteger idx, BOOL* stop)
                  {
                      NSString*    className   = NSStringFromClass([obj class]);
                      DOLog(LL_Debug, LD_General, @"obj=[%@]", className);
                      if ([className isEqualToString:@"CDOChurch"])
                      {
                          DOLog(LL_Debug, LD_General, @"obj.objectID=%@", [obj objectID]);
                          DOLog(LL_Debug, LD_General, @"obj=%@", obj);
                      }
                      if ([className isEqualToString:@"CDOFeature"])
                      {
                          DOLog(LL_Debug, LD_General, @"obj.objectID=%@", [obj objectID]);
                          DOLog(LL_Debug, LD_General, @"obj=%@", obj);
                      }
                  }];
                  */
             }
         }
         
         @try
         {
             NSError*  error;
             
             if (![context save:&error])
             {
                 DLog(LL_Error, LD_CoreData, @"ERROR saving temp context: %@", [error localizedDescription]);
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
         }
         @catch (NSException* exception)
         {
             DLog(LL_Debug, LD_General, @"exception=%@", exception);
         }
     }];
}

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext*))block
{
    if (!context)
    {
        DLog(LL_Critical, LD_CoreData, @"Invalid Context!");
    }
    if (![context isKindOfClass:[NSManagedObjectContext class]])
    {
        DLog(LL_Critical, LD_CoreData, @"Invalid Context Type! [%@]", NSStringFromClass([context class]));
    }
    if ((context == self.mainObjectContext) && ([NSThread isMainThread]))
    {
        block(context);
    }
    else
    {
        [context performBlockAndWait:
         ^()
         {
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
        [context performBlock:
         ^()
         {
             block(context);
         }];
    }
}

@end
