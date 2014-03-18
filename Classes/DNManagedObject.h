//
//  DNManagedObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNApplicationProtocol.h"

// **********
// DME: Set the default NSDate attribute value to approx Jan 1, 2970 (~1000 years in the future).  This will
//      handle the cases where a date (such as an expiration date) is not specified to designate a state of "never expires".
#define kDNDefaultDate_NeverExpires [NSDate dateWithTimeIntervalSince1970:31536000000.0f]
// **********

@class DNModel;

@interface DNManagedObject : NSManagedObject
{
    NSFetchedResultsController* fetchedResultsController;
    NSManagedObjectContext*     managedObjectContext;
}

@property (nonatomic, retain)   id  id;

+ (NSString*)entityName;
+ (DNModel*)entityModel;

+ (NSString*)pathForEntity;
+ (NSString*)requestWithParameters:(NSDictionary**)parameters
                       withContext:(NSManagedObjectContext*)context;
+ (NSDictionary*)representationsByEntityOfEntity:(NSEntityDescription*)entity
                             fromRepresentations:(id)representations;
+ (NSString*)resourceIdentifierForRepresentation:(NSDictionary*)representation
                                        ofEntity:(NSEntityDescription*)entity
                                    fromResponse:(NSHTTPURLResponse*)response;
+ (NSDictionary*)representationsByEntityForRelationshipsFromRepresentation:(NSDictionary*)representation
                                                                  ofEntity:(NSEntityDescription*)entity
                                                              fromResponse:(NSHTTPURLResponse*)response;

+ (NSString*)translationForAttribute:(NSString*)attribute
                            ofEntity:(NSEntityDescription*)entity;
+ (NSDictionary*)attributesForRepresentation:(NSDictionary*)representation
                                    ofEntity:(NSEntityDescription*)entity
                                fromResponse:(NSHTTPURLResponse*)response;
+ (NSDictionary*)representationsForRelationshipsFromRepresentation:(NSDictionary*)representation
                                                          ofEntity:(NSEntityDescription*)entity
                                                      fromResponse:(NSHTTPURLResponse*)response;
+ (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID*)objectID
                                 inManagedObjectContext:(NSManagedObjectContext*)context;
+ (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription*)relationship
                               forObjectWithID:(NSManagedObjectID*)objectID
                        inManagedObjectContext:(NSManagedObjectContext*)context;

+ (NSManagedObjectContext*)managedObjectContext;
+ (id)entityIDWithDictionary:(NSDictionary*)dict;

+ (void)saveContext;

- (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue;
- (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
- (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
- (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue;

- (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue;
- (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
- (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
- (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue;

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue;
+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
+ (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue;

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue;
+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
+ (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue;

+ (instancetype)entity;
+ (instancetype)entityFromID:(id)idValue;
+ (instancetype)entityFromDictionary:(NSDictionary*)dict;

- (instancetype)init;
- (instancetype)initWithID:(id)idValue;
- (instancetype)initWithIDIfExists:(id)idValue;
- (instancetype)initWithDictionary:(NSDictionary*)dict;

- (void)clearData;
- (void)loadWithDictionary:(NSDictionary*)dict;

- (void)saveContext;
- (void)deleteWithNoSave;
- (void)delete;

- (NSEntityDescription*)entityDescription;

#pragma mark - deleteAll

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext* context))block;
- (void)performBlock:(void (^)(NSManagedObjectContext* context))block;

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext* context))block;

- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext* context))block;

@end
