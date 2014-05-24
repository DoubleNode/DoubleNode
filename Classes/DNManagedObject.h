//
//  DNManagedObject.h
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

#import "DNApplicationProtocol.h"

// **********
// DME: Set the default NSDate attribute value to approx Jan 1, 2970 (~1000 years in the future).  This will
//      handle the cases where a date (such as an expiration date) is not specified to designate a state of "never expires".
#define kDNDefaultDate_NeverExpires [NSDate dateWithTimeIntervalSince1970:31536000000.0f]
// **********

#define CDO_DEFAULT_METHOD_PROTOTYPES(name,type)            \
+ (instancetype)name;                                       \
+ (instancetype)name##FromID:(NSNumber*)idValue;            \
+ (instancetype)name##FromIDIfExists:(NSNumber*)idValue;    \
- (BOOL)isEqualTo##type:(CDO##type*)object;

#define CDO_DEFAULT_METHOD_INSTANCES(name,type)             \
+ (Class)entityModelClass                                   \
{                                                           \
    return [CD##type##Model class];                         \
}                                                           \
                                                            \
+ (instancetype)name                                        \
{                                                           \
    return [self entity];                                   \
}                                                           \
                                                            \
+ (instancetype)name##FromID:(NSNumber*)idValue             \
{                                                           \
    return [[self alloc] initWithID:idValue];               \
}                                                           \
                                                            \
+ (instancetype)name##FromIDIfExists:(NSNumber*)idValue     \
{                                                           \
    return [[self alloc] initWithIDIfExists:idValue];       \
}                                                           \
                                                            \
- (BOOL)isEqualTo##type:(CDO##type*)object                  \
{                                                           \
    if (!object)                                            \
    {                                                       \
        return NO;                                          \
    }                                                       \
                                                            \
    return [self.objectID isEqual:object.objectID];         \
}

#define CDO_DEFAULT_STRINGID_METHOD_PROTOTYPES(name,type)   \
+ (instancetype)name;                                       \
+ (instancetype)name##FromID:(NSString*)idValue;            \
+ (instancetype)name##FromIDIfExists:(NSString*)idValue;    \
- (BOOL)isEqualTo##type:(CDO##type*)object;

#define CDO_DEFAULT_STRINGID_METHOD_INSTANCES(name,type)    \
+ (Class)entityModelClass                                   \
{                                                           \
    return [CD##type##Model class];                         \
}                                                           \
                                                            \
+ (instancetype)name                                        \
{                                                           \
    return [self entity];                                   \
}                                                           \
                                                            \
+ (instancetype)name##FromID:(NSString*)idValue             \
{                                                           \
    return [[self alloc] initWithID:idValue];               \
}                                                           \
                                                            \
+ (instancetype)name##FromIDIfExists:(NSString*)idValue     \
{                                                           \
    return [[self alloc] initWithIDIfExists:idValue];       \
}                                                           \
                                                            \
- (BOOL)isEqualTo##type:(CDO##type*)object                  \
{                                                           \
    if (!object)                                            \
    {                                                       \
        return NO;                                          \
    }                                                       \
                                                            \
    return [self.objectID isEqual:object.objectID];         \
}

#define CDO_TOMANY_ACCESSORS_PROTOTYPES(name,type)      \
- (void)add##name##Object:(CDO##type*)value;            \
- (void)remove##name##Object:(CDO##type*)value;         \
- (void)add##name:(NSSet*)values;                       \
- (void)remove##name:(NSSet*)values;

#define CDO_TOMANY_ACCESSORS_INSTANCES(name,type)

#define CDO_TOMANY_ORDERED_ACCESSORS_PROTOTYPES(name,name2,type)                        \
- (void)insertObject:(CDO##type*)value in##name##AtIndex:(NSUInteger)idx;               \
- (void)removeObjectFrom##name##AtIndex:(NSUInteger)idx;                                \
- (void)insert##name:(NSArray*)value atIndexes:(NSIndexSet*)indexes;                    \
- (void)remove##name##AtIndexes:(NSIndexSet*)indexes;                                   \
- (void)replaceObjectIn##name##AtIndex:(NSUInteger)idx withObject:(CDO##type*)value;    \
- (void)replace##name##AtIndexes:(NSIndexSet*)indexes withObjects:(NSArray*)values;     \
- (void)add##name##Object:(CDO##type*)value;                                            \
- (void)remove##name##Object:(CDO##type*)value;                                         \
- (void)add##name:(NSOrderedSet*)values;                                                \
- (void)remove##name:(NSOrderedSet*)values;

#define CDO_TOMANY_ORDERED_ACCESSORS_INSTANCES(name,name2,type)                                         \
- (void)add##name##Object:(CDO##type*)value                                                             \
{                                                                                                       \
    [self.managedObjectContext performBlockAndWait:^                                                    \
     {                                                                                                  \
         NSMutableOrderedSet*    tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.name2];   \
         [tempSet addObject:value];                                                                     \
         self.name2 = tempSet;                                                                          \
     }];                                                                                                \
}                                                                                                       \
                                                                                                        \
- (void)remove##name##Object:(CDO##type*)value                                                          \
{                                                                                                       \
    [self.managedObjectContext performBlockAndWait:^                                                    \
     {                                                                                                  \
         NSMutableOrderedSet*    tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.name2];   \
         [tempSet removeObject:value];                                                                  \
         self.name2 = tempSet;                                                                          \
     }];                                                                                                \
}

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

+ (NSString*)idAttribute;
+ (id)entityIDWithDictionary:(NSDictionary*)dict;

+ (void)saveContext;

- (NSDictionary*)serialize;
- (id)initFromSerialization:(NSDictionary*)serialization;

#pragma mark - Update If Changed functions

- (NSNumber*)updateBooleanFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSNumber*)updateNumberFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSDecimalNumber*)updateDecimalNumberFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue;
- (NSNumber*)updateDoubleFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSString*)updateStringFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue;
- (NSArray*)updateArrayFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
- (NSDictionary*)updateDictionaryFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;
- (NSDate*)updateDateFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
- (id)updateObjectFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue;

- (NSNumber*)updateBooleanFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSNumber*)updateNumberFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSDecimalNumber*)updateDecimalNumberFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue;
- (NSNumber*)updateDoubleFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSString*)updateStringFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue;
- (NSArray*)updateArrayFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
- (NSDictionary*)updateDictionaryFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;
- (NSDate*)updateDateFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
- (id)updateObjectFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue;

- (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue;
- (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue;
- (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
- (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;
- (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
- (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue;

- (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue;
- (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
- (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue;
- (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
- (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;
- (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
- (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue;

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue;
+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue;
+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;
+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
+ (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue;

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue;
+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue;
+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;
+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
+ (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue;

+ (instancetype)entity;
+ (instancetype)entityFromObjectID:(NSManagedObjectID*)objectId;
+ (instancetype)entityFromDictionary:(NSDictionary*)dict;
+ (instancetype)entityFromID:(id)idValue;

- (instancetype)init;
- (instancetype)initWithObjectID:(NSManagedObjectID*)objectId;
- (instancetype)initWithID:(id)idValue;
- (instancetype)initWithIDIfExists:(id)idValue;
- (instancetype)initWithDictionary:(NSDictionary*)dict;

- (void)clearData;
- (void)loadWithDictionary:(NSDictionary*)dict withExceptions:(NSArray*)exceptions;
- (NSDictionary*)saveToDictionary;
- (NSDictionary*)saveIDToDictionary;

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
