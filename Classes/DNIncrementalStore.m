//
//  DNIncrementalStore.m
//  Phoenix
//
//  Created by Darren Ehlers on 2/20/14.
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//

#import "DNIncrementalStore.h"

#import "DNUtilities.h"

@implementation DNIncrementalStore

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
             aboutRequestOperation:(AFHTTPRequestOperation *)operation
                   forFetchRequest:(NSFetchRequest *)fetchRequest
                  fetchedObjectIDs:(NSArray *)fetchedObjectIDs
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    [super notifyManagedObjectContext:context
                aboutRequestOperation:operation
                      forFetchRequest:fetchRequest
                     fetchedObjectIDs:fetchedObjectIDs];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
}

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
            aboutRequestOperations:(NSArray *)operations
             forSaveChangesRequest:(NSSaveChangesRequest *)saveChangesRequest
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    [super notifyManagedObjectContext:context
               aboutRequestOperations:operations
                forSaveChangesRequest:saveChangesRequest];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
}

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
             aboutRequestOperation:(AFHTTPRequestOperation *)operation
       forNewValuesForObjectWithID:(NSManagedObjectID *)objectID
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    [super notifyManagedObjectContext:context
                aboutRequestOperation:operation
          forNewValuesForObjectWithID:objectID];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
}

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
             aboutRequestOperation:(AFHTTPRequestOperation *)operation
       forNewValuesForRelationship:(NSRelationshipDescription *)relationship
                   forObjectWithID:(NSManagedObjectID *)objectID
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    [super notifyManagedObjectContext:context
                aboutRequestOperation:operation
          forNewValuesForRelationship:relationship
                      forObjectWithID:objectID];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
}

- (NSManagedObjectID *)objectIDForEntity:(NSEntityDescription *)entity
                  withResourceIdentifier:(NSString *)resourceIdentifier
{
    NSManagedObjectID*  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@", NSStringFromSelector(_cmd));
    retval = [super objectIDForEntity:entity
               withResourceIdentifier:resourceIdentifier];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@", NSStringFromSelector(_cmd));

    return retval;
}

- (NSManagedObjectID *)objectIDForBackingObjectForEntity:(NSEntityDescription *)entity
                                  withResourceIdentifier:(NSString *)resourceIdentifier
{
    NSManagedObjectID*  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@", NSStringFromSelector(_cmd));
    retval = [super objectIDForBackingObjectForEntity:entity
                               withResourceIdentifier:resourceIdentifier];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@", NSStringFromSelector(_cmd));

    return retval;
}

- (void)updateBackingObject:(NSManagedObject *)backingObject
withAttributeAndRelationshipValuesFromManagedObject:(NSManagedObject *)managedObject
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@", NSStringFromSelector(_cmd));
    [super updateBackingObject:backingObject withAttributeAndRelationshipValuesFromManagedObject:managedObject];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@", NSStringFromSelector(_cmd));
}

#pragma mark -

- (BOOL)insertOrUpdateObjectsFromRepresentations:(id)representationOrArrayOfRepresentations
                                        ofEntity:(NSEntityDescription *)entity
                                    fromResponse:(NSHTTPURLResponse *)response
                                     withContext:(NSManagedObjectContext *)context
                                           error:(NSError *__autoreleasing *)error
                                 completionBlock:(void (^)(NSArray *managedObjects, NSArray *backingObjects))completionBlock
{
    BOOL    retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    retval = [super insertOrUpdateObjectsFromRepresentations:representationOrArrayOfRepresentations
                                                    ofEntity:entity
                                                fromResponse:response
                                                 withContext:context
                                                       error:error
                                             completionBlock:completionBlock];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);

    return retval;
}

- (BOOL)insertOrUpdateObjectsFromRepresentations:(NSDictionary *)representationsByEntityName
                                    fromResponse:(NSHTTPURLResponse *)response
                                     withContext:(NSManagedObjectContext *)context
                                           error:(NSError *__autoreleasing *)error
                                 completionBlock:(void (^)(NSArray *managedObjects, NSArray *backingObjects))completionBlock
{
    BOOL    retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    retval = [super insertOrUpdateObjectsFromRepresentations:representationsByEntityName
                                                fromResponse:response
                                                 withContext:context
                                                       error:error
                                             completionBlock:completionBlock];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);

    return retval;
}

- (id)executeFetchRequest:(NSFetchRequest *)fetchRequest
              withContext:(NSManagedObjectContext *)context
                    error:(NSError *__autoreleasing *)error
{
    id  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    retval = [super executeFetchRequest:fetchRequest
                            withContext:context
                                  error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);

    return retval;
}

- (id)executeSaveChangesRequest:(NSSaveChangesRequest *)saveChangesRequest
                    withContext:(NSManagedObjectContext *)context
                          error:(NSError *__autoreleasing *)error
{
    id  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    retval = [super executeSaveChangesRequest:saveChangesRequest
                                  withContext:context
                                        error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);

    return retval;
}

- (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array
                                    error:(NSError **)error
{
    NSArray*    retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@", NSStringFromSelector(_cmd));
    retval = [super obtainPermanentIDsForObjects:array
                                           error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@", NSStringFromSelector(_cmd));

    return retval;
}

- (id)executeRequest:(NSPersistentStoreRequest *)persistentStoreRequest
         withContext:(NSManagedObjectContext *)context
               error:(NSError *__autoreleasing *)error
{
    id  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    retval = [super executeRequest:persistentStoreRequest
                       withContext:context
                             error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);

    return retval;
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                         withContext:(NSManagedObjectContext *)context
                                               error:(NSError *__autoreleasing *)error
{
    NSIncrementalStoreNode* retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    retval = [super newValuesForObjectWithID:objectID
                                 withContext:context
                                       error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);

    return retval;
}

- (id)newValueForRelationship:(NSRelationshipDescription *)relationship
              forObjectWithID:(NSManagedObjectID *)objectID
                  withContext:(NSManagedObjectContext *)context
                        error:(NSError *__autoreleasing *)error
{
    id  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);
    retval = [super newValueForRelationship:relationship
                            forObjectWithID:objectID
                                withContext:context
                                      error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"]);

    return retval;
}

- (void)managedObjectContextDidRegisterObjectsWithIDs:(NSArray *)objectIDs
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@", NSStringFromSelector(_cmd));
    [super managedObjectContextDidRegisterObjectsWithIDs:objectIDs];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@", NSStringFromSelector(_cmd));
}

- (void)managedObjectContextDidUnregisterObjectsWithIDs:(NSArray *)objectIDs
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@", NSStringFromSelector(_cmd));
    [super managedObjectContextDidUnregisterObjectsWithIDs:objectIDs];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@", NSStringFromSelector(_cmd));
}

@end
