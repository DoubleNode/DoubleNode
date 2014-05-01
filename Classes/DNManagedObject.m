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

#import "DNManagedObject.h"

#import "DNDataModel.h"
#import "DNModel.h"

#import "DNUtilities.h"
#import "NSString+HTML.h"
#import "NSString+Inflections.h"

@implementation DNManagedObject

@dynamic id;

#pragma mark - Entity description functions

+ (Class)entityModelClass
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base entityModelClass: should never be called, override might be missing!"
                                                      userInfo:nil];
    @throw exception;

    // Not sure if this is ever reached
    return nil;
}

+ (DNModel*)entityModel
{
    return [[[self entityModelClass] alloc] init];
}

+ (NSString*)entityName
{
    // Assume a 3-character prefix to class name and no suffix
    return [NSStringFromClass([self class]) substringFromIndex:3];
}

+ (id)entityIDWithDictionary:(NSDictionary*)dict
{
    if ([[dict objectForKey:@"id"] isKindOfClass:[NSString class]])
    {
        return [DNUtilities dictionaryString:dict withItem:@"id" andDefault:nil];
    }

    return [DNUtilities dictionaryNumber:dict withItem:@"id" andDefault:nil];
}

+ (NSString*)pathForEntity
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base pathForEntity: should never be called, override might be missing!"
                                                      userInfo:nil];
    @throw exception;

    // Not sure if this is ever reached
    return @"";
}

+ (NSString*)requestWithParameters:(NSDictionary**)parameters
                       withContext:(NSManagedObjectContext*)context
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base requestWithParameters:withContext: should never be called, override might be missing!"
                                                      userInfo:nil];
    @throw exception;

    // Not sure if this is ever reached
    return nil;
}

+ (NSDictionary*)representationsByEntityOfEntity:(NSEntityDescription*)entity
                             fromRepresentations:(id)representations
{
    return @{entity.name: representations};
}

+ (NSString*)resourceIdentifierForRepresentation:(NSDictionary*)representation
                                        ofEntity:(NSEntityDescription*)entity
                                    fromResponse:(NSHTTPURLResponse*)response
{
    return nil;
}

+ (NSDictionary*)representationsByEntityForRelationshipsFromRepresentation:(NSDictionary*)representation
                                                                  ofEntity:(NSEntityDescription*)entity
                                                              fromResponse:(NSHTTPURLResponse*)response
{
    return nil;
}

+ (NSString*)translationForAttribute:(NSString*)attribute
                            ofEntity:(NSEntityDescription*)entity
{
    if ([attribute rangeOfString:@"_"].location == NSNotFound)
    {
        return attribute;
    }

    NSString*   retval = [(NSString*)attribute camelizeWithLowerFirstLetter];

    return retval;
}

+ (NSDictionary*)attributesForRepresentation:(NSDictionary*)representation
                                    ofEntity:(NSEntityDescription*)entity
                                fromResponse:(NSHTTPURLResponse*)response
{
    NSMutableDictionary*    retRepresentation   = [[NSMutableDictionary alloc] initWithCapacity:representation.count];
    NSDictionary*           attributes          = [entity attributesByName];

    [representation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
     {
         if (![key isKindOfClass:[NSString class]])
         {
             return;
         }

         NSString*                  name        = [self translationForAttribute:key ofEntity:entity];
         NSAttributeDescription*    attribute   = [attributes objectForKey:name];
         if (!attribute)
         {
             return;
         }

         switch (attribute.attributeType)
         {
             case NSInteger16AttributeType:
             case NSInteger32AttributeType:
             case NSInteger64AttributeType:
             {
                 [retRepresentation setObject:[self dictionaryNumber:representation dirty:nil withItem:key andDefault:@0] forKey:name];
                 break;
             }

             case NSBooleanAttributeType:
             {
                 [retRepresentation setObject:[self dictionaryBoolean:representation dirty:nil withItem:key andDefault:@NO] forKey:name];
                 break;
             }

             case NSDecimalAttributeType:
             case NSDoubleAttributeType:
             case NSFloatAttributeType:
             {
                 [retRepresentation setObject:[self dictionaryDouble:representation dirty:nil withItem:key andDefault:@0.0f] forKey:name];
                 break;
             }

             case NSStringAttributeType:
             {
                 [retRepresentation setObject:[self dictionaryString:representation dirty:nil withItem:key andDefault:@""] forKey:name];
                 break;
             }

             case NSDateAttributeType:
             {
                 [retRepresentation setObject:[self dictionaryDate:representation dirty:nil withItem:key andDefault:kDNDefaultDate_NeverExpires] forKey:name];
                 break;
             }
         }
     }];

    return retRepresentation;
}
 
+ (NSDictionary*)representationsForRelationshipsFromRepresentation:(NSDictionary*)representation
                                                          ofEntity:(NSEntityDescription*)entity
                                                      fromResponse:(NSHTTPURLResponse*)response
{
    NSMutableDictionary*    mutableRelationshipRepresentations = [NSMutableDictionary dictionaryWithCapacity:[entity.relationshipsByName count]];
    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(id name, id relationship, BOOL* stop)
     {
         id value = [representation valueForKey:name];
         if (value)
         {
             if ([relationship isToMany])
             {
                 NSArray*   arrayOfRelationshipRepresentations = nil;
                 if ([value isKindOfClass:[NSArray class]])
                 {
                     arrayOfRelationshipRepresentations = value;
                 }
                 else
                 {
                     arrayOfRelationshipRepresentations = [NSArray arrayWithObject:value];
                 }

                 [mutableRelationshipRepresentations setValue:arrayOfRelationshipRepresentations forKey:name];
             }
             else
             {
                 [mutableRelationshipRepresentations setValue:value forKey:name];
             }
         }
     }];

    return mutableRelationshipRepresentations;
}

+ (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID*)objectID
                                 inManagedObjectContext:(NSManagedObjectContext*)context
{
    return NO;  // No detail content endpoint calls needed
}

+ (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription*)relationship
                               forObjectWithID:(NSManagedObjectID*)objectID
                        inManagedObjectContext:(NSManagedObjectContext*)context
{
    return NO;  // No detail content endpoint calls needed
}

#pragma mark - AppDelegate access functions

+ (NSManagedObjectContext*)managedObjectContext
{
    return [[[self entityModelClass] dataModel] mainObjectContext];
}

+ (void)saveContext
{
    [[[self entityModelClass] dataModel] saveContext];
}

#pragma mark - Entity initialization functions

+ (instancetype)entity
{
    return [[self alloc] init];
}

+ (instancetype)entityFromObjectID:(NSManagedObjectID*)objectId
{
    return [[self alloc] initWithObjectID:objectId];
}

+ (instancetype)entityFromDictionary:(NSDictionary*)dict
{
    return [[self alloc] initWithDictionary:dict];
}

+ (instancetype)entityFromID:(id)idValue
{
    return [[self alloc] initWithID:idValue];
}

- (NSDictionary*)serialize
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base serialize should not be called, functionality not implemented yet!"
                                                      userInfo:nil];
    @throw exception;

    // Not sure if this is ever reached
    return nil;
}

- (id)initFromSerialization:(NSDictionary*)serialization
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base initFromSerialization: should not be called, functionality not implemented yet!"
                                                      userInfo:nil];
    @throw exception;

    // Not sure if this is ever reached
    return nil;
}

- (instancetype)init
{
    __block DNManagedObject*    bself   = self;

    [self performBlockAndWait:^(NSManagedObjectContext* context)
     {
         NSEntityDescription*    entity = [NSEntityDescription entityForName:[[self class] entityName] inManagedObjectContext:context];

         bself = [self initWithEntity:entity insertIntoManagedObjectContext:context];
     }];

    self = bself;
    if (self)
    {
        [self clearData];
    }
    
    return self;
}

- (instancetype)initWithObjectID:(NSManagedObjectID*)objectId
{
    __block DNManagedObject*    bself   = self;

    [self performBlockAndWait:^(NSManagedObjectContext* context)
     {
         NSError*   error = nil;
         bself = (DNManagedObject*)[context existingObjectWithID:objectId error:&error];
     }];

    self = bself;

    return self;
}

- (instancetype)initWithID:(id)idValue
{
    id  newSelf = [[[self class] entityModel] getFromID:idValue];
    if (newSelf == nil)
    {
        newSelf = [self init];
    }
    
    self = newSelf;
    if (self)
    {
        self.id = idValue;
    }
    
    return self;
}

- (instancetype)initWithIDIfExists:(id)idValue
{
    id  newSelf = [[[self class] entityModel] getFromID:idValue];
    if (newSelf == nil)
    {
        //newSelf = [self init];
    }

    self = newSelf;
    if (self)
    {
        self.id = idValue;
    }

    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    id  idValue = [[self class] entityIDWithDictionary:dict];
    
    id  newSelf = [[[self class] entityModel] getFromID:idValue];
    if (newSelf == nil)
    {
        newSelf = [self init];
    }
    
    self = newSelf;
    if (self)
    {
        self.id = idValue;
        
        [self loadWithDictionary:dict];
    }
    
    return self;
}

- (void)clearData
{
    /*
    @try
    {
        self.id = nil;
    }
    @catch (NSException *exception)
    {
        DLog(LL_Warning, LD_CoreData, @"exception=%@", exception);
    }
     */
}

- (void)loadWithDictionary:(NSDictionary*)dict
{
    self.id  = [[self class] entityIDWithDictionary:dict];
}

- (NSDictionary*)saveToDictionary
{
    return [self saveIDToDictionary];
}

- (NSDictionary*)saveIDToDictionary
{
    [self.managedObjectContext obtainPermanentIDsForObjects:[NSArray arrayWithObject:self] error:nil];

    return @{
             @"id"          : self.id,
             @"objectID"    : [[[self objectID] URIRepresentation] absoluteString]
             };
}

#pragma mark - Entity save/delete functions

- (void)saveContext;
{
    [[self class] saveContext];
}

- (void)deleteWithNoSave
{
    [self performBlock:^(NSManagedObjectContext* context)
     {
         [context deleteObject:self];
     }];
}

- (void)delete
{
    [self deleteWithNoSave];
    [self performBlock:^(NSManagedObjectContext* context)
     {
         [context processPendingChanges];
     }];
    [self saveContext];
}

#pragma mark - Entity Description functions

- (NSEntityDescription*)entityDescription
{
    __block NSEntityDescription*    retval;

    //[self performBlockAndWait:^(NSManagedObjectContext* context)
    // {
         retval = [NSEntityDescription entityForName:[[self class] entityName]
                              inManagedObjectContext:[[self class] managedObjectContext]];
    // }];

    return retval;
}

#pragma mark - Dictionary Translation functions

- (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryBoolean:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryBoolean:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

- (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryNumber:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

- (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue
{
    return [DNUtilities dictionaryDecimalNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue
{
    return [DNUtilities dictionaryDecimalNumber:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

- (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryDouble:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryDouble:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

- (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [DNUtilities dictionaryString:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [DNUtilities dictionaryString:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

- (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [DNUtilities dictionaryArray:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [DNUtilities dictionaryArray:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

- (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [DNUtilities dictionaryDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [DNUtilities dictionaryDate:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

- (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [DNUtilities dictionaryObject:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [DNUtilities dictionaryObject:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryBoolean:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryBoolean:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryNumber:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue
{
    return [DNUtilities dictionaryDecimalNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSDecimalNumber*)dictionaryDecimalNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue
{
    return [DNUtilities dictionaryDecimalNumber:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryDouble:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [DNUtilities dictionaryDouble:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [DNUtilities dictionaryString:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [DNUtilities dictionaryString:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [DNUtilities dictionaryArray:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [DNUtilities dictionaryArray:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [DNUtilities dictionaryDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [DNUtilities dictionaryDate:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

+ (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [DNUtilities dictionaryObject:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [DNUtilities dictionaryObject:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
}

#pragma mark - private methods

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[[self class] managedObjectContext]
                blockAndWait:block];
}

- (void)performBlock:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[[self class] managedObjectContext]
                       block:block];
}

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext* context))block
{
    [[[self class] entityModel] performWithContext:context
                                      blockAndWait:block];
}

- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext* context))block
{
    [[[self class] entityModel] performWithContext:context
                                             block:block];
}

@end
