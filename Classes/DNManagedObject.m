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
#import "NSInvocation+Constructors.h"

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
    return [[[self entityModelClass] dataModel] currentObjectContext];
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
        if (![self.id isEqual:idValue])
        {
            self.id = idValue;
        }
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
        if (![self.id isEqual:idValue])
        {
            self.id = idValue;
        }
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
        if (![self.id isEqual:idValue])
        {
            self.id = idValue;
        }
        
        [self loadWithDictionary:dict withExceptions:nil];
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
    id  newId   = [[self class] entityIDWithDictionary:dict];
    if (![self.id isEqual:newId])
    {
        self.id  = newId;
    }
}

- (void)loadWithDictionary:(NSDictionary*)dict
            withExceptions:(NSArray*)exceptions
{
    id  newId   = [[self class] entityIDWithDictionary:dict];
    if (![self.id isEqual:newId])
    {
        self.id  = newId;
    }

    NSDictionary*   attributes  = [self.entity attributesByName];

    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, NSAttributeDescription* attribute, BOOL* stop)
     {
         if (![key isKindOfClass:[NSString class]])
         {
             DLog(LL_Debug, LD_General, @"load: NOTSTRING key=%@", key);
             return;
         }

         if (exceptions && [exceptions containsObject:key])
         {
             DLog(LL_Debug, LD_General, @"load: SKIPPING key=%@", key);
             return;
         }

         if ([key isEqualToString:@"id"])
         {
             DLog(LL_Debug, LD_General, @"load: ID key=%@", key);
             return;
         }

         DLog(LL_Debug, LD_General, @"load: key=%@", key);
         id defaultValue    = [self valueForKey:key];

         switch (attribute.attributeType)
         {
             case NSInteger16AttributeType:
             case NSInteger32AttributeType:
             case NSInteger64AttributeType:
             {
                 DLog(LL_Debug, LD_General, @"load: updateNumberFieldIfChanged");
                 [self updateNumberFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                 break;
             }

             case NSBooleanAttributeType:
             {
                 DLog(LL_Debug, LD_General, @"load: updateBooleanFieldIfChanged");
                 [self updateBooleanFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                 break;
             }

             case NSDecimalAttributeType:
             {
                 DLog(LL_Debug, LD_General, @"load: updateDecimalNumberFieldIfChanged");
                 [self updateDecimalNumberFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                 break;
             }

             case NSDoubleAttributeType:
             case NSFloatAttributeType:
             {
                 DLog(LL_Debug, LD_General, @"load: updateDoubleFieldIfChanged");
                 [self updateDoubleFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                 break;
             }

             case NSStringAttributeType:
             {
                 DLog(LL_Debug, LD_General, @"load: updateStringFieldIfChanged");
                 [self updateStringFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                 break;
             }

             case NSDateAttributeType:
             {
                 DLog(LL_Debug, LD_General, @"load: updateDateFieldIfChanged");
                 if (!defaultValue)
                 {
                     defaultValue   = kDNDefaultDate_NeverExpires;
                 }
                 [self updateDateFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                 break;
             }
         }
     }];

    NSDictionary*   relationships   = [self.entity relationshipsByName];

    [relationships enumerateKeysAndObjectsUsingBlock:^(id key, NSRelationshipDescription* relationship, BOOL* stop)
     {
         if (![key isKindOfClass:[NSString class]])
         {
             DLog(LL_Debug, LD_General, @"loadRelate: NOTSTRING key=%@", key);
             return;
         }

         if (exceptions && [exceptions containsObject:key])
         {
             DLog(LL_Debug, LD_General, @"loadRelate: SKIPPING key=%@", key);
             return;
         }

         if ([relationship isToMany])
         {
             DLog(LL_Debug, LD_General, @"loadRelateToMany: key=%@", key);
             if (dict[key] && ![dict[key] isKindOfClass:[NSNull class]])
             {
                 [dict[key] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
                  {
                      Class  cdoSubClass = NSClassFromString([NSString stringWithFormat:@"CDO%@", [relationship.destinationEntity name]]);

                      id     newObject  = [cdoSubClass entityFromDictionary:obj];

                      NSString*  addObjectMethodName  = [NSString stringWithFormat:@"add%@Object", [relationship.destinationEntity name]];

                      //[self addCommentsObject:newObject];
                  }];
             }
         }
         else
         {
             DLog(LL_Debug, LD_General, @"loadRelateToOne: key=%@", key);
             if (dict[key] && ![dict[key] isKindOfClass:[NSNull class]])
             {
                 Class  cdoSubClass = NSClassFromString([NSString stringWithFormat:@"CDO%@", [relationship.destinationEntity name]]);

                 id     existingObject  = [self valueForKey:key];
                 id     newObject       = [cdoSubClass entityFromDictionary:dict[key]];

                 BOOL   isEqual = NO;

                 NSString*  equalityMethodName  = [NSString stringWithFormat:@"isEqualTo%@", [relationship.destinationEntity name]];
                 if ([existingObject respondsToSelector:@selector(equalityMethodName)])
                 {
                     NSInvocation*  inv = [NSInvocation invocationWithTarget:existingObject
                                                                    selector:@selector(equalityMethodName)];
                     [inv invoke];
                     [inv getReturnValue:&isEqual];
                 }

                 if (!isEqual)
                 {
                     [self setValue:newObject forKey:key];
                 }
             }
         }
     }];
}

- (NSDictionary*)saveToDictionary
{
    NSMutableDictionary*    dict        = [[self saveIDToDictionary] mutableCopy];
    NSDictionary*           attributes  = [self.entity attributesByName];

    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, NSAttributeDescription* attribute, BOOL* stop)
     {
         if (![key isKindOfClass:[NSString class]])
         {
             DLog(LL_Debug, LD_General, @"save: NOTSTRING key=%@", key);
             return;
         }

         if ([key isEqualToString:@"id"])
         {
             DLog(LL_Debug, LD_General, @"save: ID key=%@", key);
             return;
         }

         DLog(LL_Debug, LD_General, @"save: key=%@", key);
         id currentValue    = [self valueForKey:key];

         if (currentValue)
         {
             dict[key]  = currentValue;
         }
     }];

    return dict;
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

#pragma mark - Update If Changed functions

- (NSNumber*)updateBooleanFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [self updateBooleanFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)updateBooleanFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryBoolean:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (NSNumber*)updateNumberFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [self updateNumberFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)updateNumberFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryNumber:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (NSDecimalNumber*)updateDecimalNumberFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue
{
    return [self updateDecimalNumberFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSDecimalNumber*)updateDecimalNumberFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDecimalNumber*)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryDecimalNumber:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (NSNumber*)updateDoubleFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [self updateDoubleFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)updateDoubleFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryDouble:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (NSString*)updateStringFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [self updateStringFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSString*)updateStringFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryString:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (NSArray*)updateArrayFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [self updateArrayFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSArray*)updateArrayFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryArray:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (NSDictionary*)updateDictionaryFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    return [self updateDictionaryFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSDictionary*)updateDictionaryFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryDictionary:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (NSDate*)updateDateFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [self updateDateFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSDate*)updateDateFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryDate:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (id)updateObjectFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [self updateObjectFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (id)updateObjectFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue
{
    BOOL    localDirtyFlag;
    if (!dirtyFlag) {   dirtyFlag = &localDirtyFlag;    }

    *dirtyFlag  = NO;
    id  newValue = [self dictionaryObject:dictionary dirty:dirtyFlag withItem:key andDefault:[self valueForKeyPath:keypath]];
    if (*dirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
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

- (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    return [DNUtilities dictionaryDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    return [DNUtilities dictionaryDictionary:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
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

+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    return [DNUtilities dictionaryDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    return [DNUtilities dictionaryDictionary:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
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
