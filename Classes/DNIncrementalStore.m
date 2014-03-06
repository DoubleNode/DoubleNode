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
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ operation:%@ fetchRequest:%@ fetchedObjectIDs=%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], operation, fetchRequest, fetchedObjectIDs);
    [super notifyManagedObjectContext:context
                aboutRequestOperation:operation
                      forFetchRequest:fetchRequest
                     fetchedObjectIDs:fetchedObjectIDs];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ operation:%@ fetchRequest:%@ fetchedObjectIDs=%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], operation, fetchRequest, fetchedObjectIDs);
}

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
            aboutRequestOperations:(NSArray *)operations
             forSaveChangesRequest:(NSSaveChangesRequest *)saveChangesRequest
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ operation:%@ saveChangesRequest=%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], operations, saveChangesRequest);
    [super notifyManagedObjectContext:context
               aboutRequestOperations:operations
                forSaveChangesRequest:saveChangesRequest];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ operation:%@ saveChangesRequest=%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], operations, saveChangesRequest);
}

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
             aboutRequestOperation:(AFHTTPRequestOperation *)operation
       forNewValuesForObjectWithID:(NSManagedObjectID *)objectID
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ operation:%@ objectID=%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], operation, objectID);
    [super notifyManagedObjectContext:context
                aboutRequestOperation:operation
          forNewValuesForObjectWithID:objectID];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ operation:%@ objectID=%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], operation, objectID);
}

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
             aboutRequestOperation:(AFHTTPRequestOperation *)operation
       forNewValuesForRelationship:(NSRelationshipDescription *)relationship
                   forObjectWithID:(NSManagedObjectID *)objectID
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ operation:%@ relationship=%@ objectID=%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], operation, relationship, objectID);
    [super notifyManagedObjectContext:context
                aboutRequestOperation:operation
          forNewValuesForRelationship:relationship
                      forObjectWithID:objectID];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ operation:%@ relationship=%@ objectID=%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], operation, relationship, objectID);
}

- (NSManagedObjectID *)objectIDForEntity:(NSEntityDescription *)entity
                  withResourceIdentifier:(NSString *)resourceIdentifier
{
    NSManagedObjectID*  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ entity:%@ resourceID:%@", NSStringFromSelector(_cmd), [entity name], resourceIdentifier);
    retval = [super objectIDForEntity:entity
               withResourceIdentifier:resourceIdentifier];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ entity:%@ resourceID:%@ retval:%@", NSStringFromSelector(_cmd), [entity name], resourceIdentifier, retval);

    return retval;
}

- (NSManagedObjectID *)objectIDForBackingObjectForEntity:(NSEntityDescription *)entity
                                  withResourceIdentifier:(NSString *)resourceIdentifier
{
    NSManagedObjectID*  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ entity:%@ resourceID:%@", NSStringFromSelector(_cmd), [entity name], resourceIdentifier);
    retval = [super objectIDForBackingObjectForEntity:entity
                               withResourceIdentifier:resourceIdentifier];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ entity:%@ resourceID:%@ retval:%@", NSStringFromSelector(_cmd), [entity name], resourceIdentifier, retval);

    return retval;
}

- (void)updateBackingObject:(NSManagedObject *)backingObject
withAttributeAndRelationshipValuesFromManagedObject:(NSManagedObject *)managedObject
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ backingObject:%@ managedObject:%@", NSStringFromSelector(_cmd), backingObject, managedObject);
    [super updateBackingObject:backingObject withAttributeAndRelationshipValuesFromManagedObject:managedObject];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ backingObject:%@ managedObject:%@", NSStringFromSelector(_cmd), backingObject, managedObject);
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
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ retval:%@ error:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], (retval ? @"YES" : @"NO"), ((error == NULL) ? @"<NONE>" : *error));

    return retval;
}

- (BOOL)insertOrUpdateObjectsFromRepresentations:(NSDictionary *)representationsByEntityName
                                    fromResponse:(NSHTTPURLResponse *)response
                                     withContext:(NSManagedObjectContext *)context
                                           error:(NSError *__autoreleasing *)error
                                 completionBlock:(void (^)(NSArray *managedObjects, NSArray *backingObjects))completionBlock
{
    BOOL    retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ representations:%@ response:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], representationsByEntityName, response);
    retval = [super insertOrUpdateObjectsFromRepresentations:representationsByEntityName
                                                fromResponse:response
                                                 withContext:context
                                                       error:error
                                             completionBlock:completionBlock];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ representations:%@ response:%@ retval:%@ error:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], representationsByEntityName, response, (retval ? @"YES" : @"NO"), ((error == NULL) ? @"<NONE>" : *error));

    return retval;
}

- (id)executeFetchRequest:(NSFetchRequest *)fetchRequest
              withContext:(NSManagedObjectContext *)context
                    error:(NSError *__autoreleasing *)error
{
    id  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ request:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], fetchRequest);
    retval = [super executeFetchRequest:fetchRequest
                            withContext:context
                                  error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ request:%@ retval:%@ error:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], fetchRequest, retval, ((error == NULL) ? @"<NONE>" : *error));

    return retval;
}

- (id)executeSaveChangesRequest:(NSSaveChangesRequest *)saveChangesRequest
                    withContext:(NSManagedObjectContext *)context
                          error:(NSError *__autoreleasing *)error
{
    id  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ request:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], saveChangesRequest);
    retval = [super executeSaveChangesRequest:saveChangesRequest
                                  withContext:context
                                        error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ request:%@ retval:%@ error:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], saveChangesRequest, retval, ((error == NULL) ? @"<NONE>" : *error));

    return retval;
}

- (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array
                                    error:(NSError **)error
{
    NSArray*    retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ array:%@", NSStringFromSelector(_cmd), array);
    retval = [super obtainPermanentIDsForObjects:array
                                           error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ array:%@ retval:%@ error:%@", NSStringFromSelector(_cmd), array, retval, ((error == NULL) ? @"<NONE>" : *error));

    return retval;
}

- (id)executeRequest:(NSPersistentStoreRequest *)persistentStoreRequest
         withContext:(NSManagedObjectContext *)context
               error:(NSError *__autoreleasing *)error
{
    id  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ request:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], persistentStoreRequest);
    retval = [super executeRequest:persistentStoreRequest
                       withContext:context
                             error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ request:%@ retval:%@ error:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], persistentStoreRequest, retval, ((error == NULL) ? @"<NONE>" : *error));

    return retval;
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                         withContext:(NSManagedObjectContext *)context
                                               error:(NSError *__autoreleasing *)error
{
    NSIncrementalStoreNode* retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ objectID:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], objectID);
    retval = [super newValuesForObjectWithID:objectID
                                 withContext:context
                                       error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ objectID:%@ retval:%@ error:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], objectID, retval, ((error == NULL) ? @"<NONE>" : *error));

    return retval;
}

- (id)newValueForRelationship:(NSRelationshipDescription *)relationship
              forObjectWithID:(NSManagedObjectID *)objectID
                  withContext:(NSManagedObjectContext *)context
                        error:(NSError *__autoreleasing *)error
{
    id  retval;

    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ context:%@ objectID:%@ relationship:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], objectID, relationship);
    retval = [super newValueForRelationship:relationship
                            forObjectWithID:objectID
                                withContext:context
                                      error:error];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ context:%@ objectID:%@ relationship:%@ retval:%@ error:%@", NSStringFromSelector(_cmd), [context.userInfo objectForKey:@"mocName"], objectID, relationship, retval, ((error == NULL) ? @"<NONE>" : *error));

    return retval;
}

- (void)managedObjectContextDidRegisterObjectsWithIDs:(NSArray *)objectIDs
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ objectIDs:%@", NSStringFromSelector(_cmd), objectIDs);
    [super managedObjectContextDidRegisterObjectsWithIDs:objectIDs];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ objectIDs:%@", NSStringFromSelector(_cmd), objectIDs);
}

- (void)managedObjectContextDidUnregisterObjectsWithIDs:(NSArray *)objectIDs
{
    DLog(LL_Debug, LD_CoreDataIS, @"IN: %@ objectIDs:%@", NSStringFromSelector(_cmd), objectIDs);
    [super managedObjectContextDidUnregisterObjectsWithIDs:objectIDs];
    DLog(LL_Debug, LD_CoreDataIS, @"OUT: %@ objectIDs:%@", NSStringFromSelector(_cmd), objectIDs);
}

@end
