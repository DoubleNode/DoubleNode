//
//  DNIncrementalStore.h
//  Phoenix
//
//  Created by Darren Ehlers on 2/20/14.
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//

#import "AFIncrementalStore.h"

@interface AFIncrementalStore (_DNExternal)

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
             aboutRequestOperation:(AFHTTPRequestOperation *)operation
                   forFetchRequest:(NSFetchRequest *)fetchRequest
                  fetchedObjectIDs:(NSArray *)fetchedObjectIDs;

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
            aboutRequestOperations:(NSArray *)operations
             forSaveChangesRequest:(NSSaveChangesRequest *)saveChangesRequest;

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
             aboutRequestOperation:(AFHTTPRequestOperation *)operation
       forNewValuesForObjectWithID:(NSManagedObjectID *)objectID;

- (void)notifyManagedObjectContext:(NSManagedObjectContext *)context
             aboutRequestOperation:(AFHTTPRequestOperation *)operation
       forNewValuesForRelationship:(NSRelationshipDescription *)relationship
                   forObjectWithID:(NSManagedObjectID *)objectID;

- (NSManagedObjectID *)objectIDForEntity:(NSEntityDescription *)entity
                  withResourceIdentifier:(NSString *)resourceIdentifier;

- (NSManagedObjectID *)objectIDForBackingObjectForEntity:(NSEntityDescription *)entity
                                  withResourceIdentifier:(NSString *)resourceIdentifier;

- (void)updateBackingObject:(NSManagedObject *)backingObject
withAttributeAndRelationshipValuesFromManagedObject:(NSManagedObject *)managedObject;

- (BOOL)insertOrUpdateObjectsFromRepresentations:(id)representationOrArrayOfRepresentations
                                        ofEntity:(NSEntityDescription *)entity
                                    fromResponse:(NSHTTPURLResponse *)response
                                     withContext:(NSManagedObjectContext *)context
                                           error:(NSError *__autoreleasing *)error
                                 completionBlock:(void (^)(NSArray *managedObjects, NSArray *backingObjects))completionBlock;

- (BOOL)insertOrUpdateObjectsFromRepresentations:(NSDictionary *)representationsByEntityName
                                    fromResponse:(NSHTTPURLResponse *)response
                                     withContext:(NSManagedObjectContext *)context
                                           error:(NSError *__autoreleasing *)error
                                 completionBlock:(void (^)(NSArray *managedObjects, NSArray *backingObjects))completionBlock;

@end

@interface DNIncrementalStore : AFIncrementalStore

@end
