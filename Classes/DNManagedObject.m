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

#import "DNDate.h"

#import "DNUtilities.h"
#import "NSString+HTML.h"
#import "NSString+Inflections.h"
#import "NSInvocation+Constructors.h"
#import "NSDate+Unix.h"

@implementation DNManagedObject

@dynamic id;

#pragma mark - Entity description functions

- (void)prepareForDeletion
{
    [super prepareForDeletion];
}

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

+ (NSString*)idAttribute
{
    return @"id";
}

+ (NSString*)addedAttribute
{
    return @"added";
}

+ (id)entityIDWithDictionary:(NSDictionary*)dict
{
    //if ([[dict objectForKey:@"id"] isKindOfClass:[NSString class]])
    //{
    //    return [DNUtilities dictionaryString:dict withItem:@"id" andDefault:nil];
    //}

    return [DNUtilities dictionaryNumber:dict withItem:[[self class] idAttribute] andDefault:nil];
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

    [representation enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL* stop)
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
                 retRepresentation[name]    = [self dictionaryNumber:representation dirty:nil withItem:key andDefault:@0];
                 break;
             }

             case NSBooleanAttributeType:
             {
                 retRepresentation[name]    = [self dictionaryBoolean:representation dirty:nil withItem:key andDefault:@NO];
                 break;
             }

             case NSDecimalAttributeType:
             case NSDoubleAttributeType:
             case NSFloatAttributeType:
             {
                 retRepresentation[name]    = [self dictionaryDouble:representation dirty:nil withItem:key andDefault:@0.0f];
                 break;
             }

             case NSStringAttributeType:
             {
                 retRepresentation[name]    = [self dictionaryString:representation dirty:nil withItem:key andDefault:@""];
                 break;
             }

             case NSDateAttributeType:
             {
                 retRepresentation[name]    = [self dictionaryDate:representation dirty:nil withItem:key andDefault:kDNDefaultDate_NeverExpires];
                 break;
             }
                 
             case NSTransformableAttributeType:
             {
                 unsigned  dateFlags            = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute;
                 DNDate*   defaultDNDateValue   = [DNDate dateWithComponentFlags:dateFlags fromDate:kDNDefaultDate_NeverExpires];
                 retRepresentation[name]        = [self dictionaryDNDate:representation dirty:nil withItem:key andDefault:defaultDNDateValue];
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
    NSMutableDictionary*    retRepresentation   = [NSMutableDictionary dictionaryWithCapacity:[entity.relationshipsByName count]];
    NSDictionary*           relationships       = [entity relationshipsByName];

    [representation enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL* stop)
     {
         if (![key isKindOfClass:[NSString class]])
         {
             return;
         }

         NSString*  name    = [self translationForAttribute:key ofEntity:entity];

         NSRelationshipDescription* relationship    = relationships[name];
         if (!relationship)
         {
             name           = [name pluralize];
             relationship   = relationships[name];
         }
         if (!relationship)
         {
             return;
         }

         id value = [representation valueForKey:key];
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
                     arrayOfRelationshipRepresentations = @[ value ];
                 }

                 [retRepresentation setValue:arrayOfRelationshipRepresentations forKey:name];
             }
             else
             {
                 [retRepresentation setValue:value forKey:name];
             }
         }
     }];

    return retRepresentation;
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
    __block id  retval;
    
    [self.managedObjectContext performBlockAndWait:
     ^()
     {
         NSEntityDescription*    entity = [NSEntityDescription entityForName:[self entityName]
                                                      inManagedObjectContext:self.managedObjectContext];
         
         retval = [[self alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
         
         NSError*   error;
         if (![self.managedObjectContext obtainPermanentIDsForObjects:@[ retval ] error:&error])
         {
             DLog(LL_Debug, LD_General, @"error=%@", error);
         }
     }];
    
    return retval;
}

+ (instancetype)entityFromObjectID:(NSManagedObjectID*)objectId
{
    __block id  retval;
    
    [self.managedObjectContext performBlockAndWait:
     ^()
     {
         NSError*   error;
         retval = [self.managedObjectContext existingObjectWithID:objectId
                                                            error:&error];
         if (!retval)
         {
             DLog(LL_Debug, LD_General, @"error=%@", error);
         }
     }];
    
    return retval;
}

+ (instancetype)entityFromDictionary:(NSDictionary*)dict
{
    id  idValue = [self entityIDWithDictionary:dict];

    id  retval  = [self entityFromID:idValue];
    if (retval)
    {
        [retval loadWithDictionary:dict withExceptions:nil];
    }
    
    return retval;
}

+ (instancetype)entityFromID:(id)idValue
{
    id  retval  = [[self entityModel] getFromID:idValue];
    if (!retval)
    {
        retval = [self entity];
    }

    if (retval)
    {
        [retval setIdIfChanged:idValue];
    }
    
    return retval;
}

+ (instancetype)entityFromIDIfExists:(id)idValue
{
    return [[self entityModel] getFromID:idValue];
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

    [self performBlockAndWait:
     ^(NSManagedObjectContext* context)
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

    [self performBlockAndWait:
     ^(NSManagedObjectContext* context)
     {
         bself = (DNManagedObject*)[context existingObjectWithID:objectId error:NULL];
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
            [self setIdIfChanged:idValue];
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
            [self setIdIfChanged:idValue];
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
        [self setIdIfChanged:idValue];

        [self loadWithDictionary:dict withExceptions:nil];
    }

    return self;
}

- (id)objectInCurrentContext
{
    return [self objectInContext:nil];
}

- (id)objectInContext:(NSManagedObjectContext*)pContext
{
    NSManagedObjectContext* context = pContext;
    
    if (!context)
    {
        DNDataModel*    dataModel   = [[[[self class] entityModel] class] dataModel];
        
        context = [dataModel currentObjectContext];
    }

    __block id  retval;
    
    [self performWithContext:context
                blockAndWait:
     ^(NSManagedObjectContext* context)
     {
         retval = [context objectWithID:self.objectID];
     }];

    return retval;
}

- (void)setIdIfChanged:(id)idValue
{
    NSDictionary*           attributes  = [self.entity attributesByName];
    NSAttributeDescription* attribute   = attributes[[[self class] idAttribute]];
    BOOL                    stringFlag  = NO;
    if (attribute && (attribute.attributeType == NSStringAttributeType))
    {
        stringFlag  = YES;
    }
    
    [self performBlockAndWait:
     ^(NSManagedObjectContext* context)
     {
         if (stringFlag)
         {
             if (![self.id isEqualToString:[NSString stringWithFormat:@"%@", idValue]])
             {
                 self.id = [NSString stringWithFormat:@"%@", idValue];
             }
         }
         else
         {
             NSNumber*   newValue;
             if ([idValue isKindOfClass:[NSString class]])
             {
                 newValue = [NSNumber numberWithInteger:(int)[idValue intValue]];
             }
             else
             {
                 newValue = idValue;
             }
             
             if (newValue)
             {
                 if (![self.id isEqualToNumber:newValue])
                 {
                     self.id = newValue;
                 }
             }
             else
             {
                 self.id = nil;
             }
         }
     }];
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
            withExceptions:(NSArray*)exceptions
{
    [self performBlockAndWait:
     ^(NSManagedObjectContext* context)
     {
         NSDictionary*   attributes  = [self.entity attributesByName];
         
         [attributes enumerateKeysAndObjectsUsingBlock:
          ^(id key, NSAttributeDescription* attribute, BOOL* stop)
          {
              if (![key isKindOfClass:[NSString class]])
              {
                  DLog(LL_Debug, LD_General, @"load: NOTSTRING key=%@", key);
                  return;
              }
              
              if (exceptions && [exceptions containsObject:key])
              {
                  //DLog(LL_Debug, LD_General, @"load: SKIPPING key=%@", key);
                  return;
              }
              
              if ([key isEqualToString:[[self class] idAttribute]])
              {
                  //DLog(LL_Debug, LD_General, @"load: ID key=%@", key);
                  return;
              }
              
              //DLog(LL_Debug, LD_General, @"load: key=%@", key);
              id defaultValue    = [self valueForKey:key];
              
              switch (attribute.attributeType)
              {
                  case NSInteger16AttributeType:
                  case NSInteger32AttributeType:
                  case NSInteger64AttributeType:
                  {
                      //DLog(LL_Debug, LD_General, @"load: updateNumberFieldIfChanged");
                      [self updateNumberFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                      break;
                  }
                      
                  case NSBooleanAttributeType:
                  {
                      //DLog(LL_Debug, LD_General, @"load: updateBooleanFieldIfChanged");
                      [self updateBooleanFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                      break;
                  }
                      
                  case NSDecimalAttributeType:
                  {
                      //DLog(LL_Debug, LD_General, @"load: updateDecimalNumberFieldIfChanged");
                      [self updateDecimalNumberFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                      break;
                  }
                      
                  case NSDoubleAttributeType:
                  case NSFloatAttributeType:
                  {
                      //DLog(LL_Debug, LD_General, @"load: updateDoubleFieldIfChanged");
                      [self updateDoubleFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                      break;
                  }
                      
                  case NSStringAttributeType:
                  {
                      //DLog(LL_Debug, LD_General, @"load: updateStringFieldIfChanged");
                      [self updateStringFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                      break;
                  }
                      
                  case NSDateAttributeType:
                  {
                      //DLog(LL_Debug, LD_General, @"load: updateDateFieldIfChanged");
                      if (!defaultValue || ![defaultValue isKindOfClass:[NSDate class]])
                      {
                          defaultValue   = kDNDefaultDate_NeverExpires;
                      }
                      [self updateDateFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultValue];
                      break;
                  }
                      
                  case NSTransformableAttributeType:
                  {
                      unsigned  dateFlags           = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute;
                      DNDate*   defaultDNDateValue  = [DNDate dateWithComponentFlags:dateFlags fromDate:kDNDefaultDate_NeverExpires];
                      [self updateDNDateFieldIfChanged:key fromDictionary:dict withItem:key andDefault:defaultDNDateValue];
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
                  //DLog(LL_Debug, LD_General, @"loadRelate: SKIPPING key=%@", key);
                  return;
              }
              
              //DLog(LL_Debug, LD_General, @"entity=%@: key=%@", self.entity.name, key);
              if ([relationship isToMany])
              {
                  //DLog(LL_Debug, LD_General, @"loadRelateToMany: key=%@", key);
                  if (dict[key] && ![dict[key] isKindOfClass:[NSNull class]])
                  {
                      //if ([key isEqualToString:@"features"])
                      //{
                      //    DLog(LL_Debug, LD_General, @"entity=%@: key=%@", self.entity.name, key);
                      //}
                      
                      id arrayValue  = dict[key];
                      if (![arrayValue isKindOfClass:[NSArray class]])
                      {
                          arrayValue = nil;
                      }
                      [arrayValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
                       {
                           if (obj && ![obj isEqual:[NSNull null]])
                           {
                               Class  cdoSubClass = NSClassFromString([NSString stringWithFormat:@"CDO%@", [relationship.destinationEntity name]]);
                               
                               /*
                                NSEntityDescription*   entityDescription   = [NSEntityDescription entityForName:[relationship.destinationEntity name]
                                inManagedObjectContext:[cdoSubClass managedObjectContext]];
                                
                                NSMutableDictionary*   objectD = [[cdoSubClass representationsForRelationshipsFromRepresentation:obj
                                ofEntity:entityDescription
                                fromResponse:nil] mutableCopy];
                                
                                [objectD addEntriesFromDictionary:[cdoSubClass attributesForRepresentation:obj
                                ofEntity:entityDescription
                                fromResponse:nil]];
                                
                                id     newObject  = [cdoSubClass entityFromDictionary:objectD];
                                */
                               
                               NSMutableDictionary*  objMD   = [obj mutableCopy];
                               objMD[@"_relationship"]       = key;
                               
                               [[cdoSubClass entityModel] performBlockAndWait:
                                ^(NSManagedObjectContext* context)
                                {
                                    id     newObject  = [cdoSubClass entityFromDictionary:objMD];
                                    if (newObject)
                                    {
                                        NSString*  addObjectMethodName  = [NSString stringWithFormat:@"add%@Object:", [[[relationship name] underscore] camelize]];
                                        SEL        addObjectSelector    = NSSelectorFromString(addObjectMethodName);
                                        
                                        if ([self respondsToSelector:addObjectSelector])
                                        {
                                            NSInvocation*  inv = [NSInvocation invocationWithTarget:self
                                                                                           selector:addObjectSelector];
                                            [inv setArgument:&newObject atIndex:2];
                                            [inv invoke];
                                        }
                                        else
                                        {
                                            DLog(LL_Debug, LD_CoreData, @"No Selector Match: %@", NSStringFromSelector(addObjectSelector));
                                        }
                                        //DLog(LL_Debug, LD_CoreData, @"Trace Point [%@] sub=%@", NSStringFromClass([self class]), NSStringFromClass([newObject class]));
                                    }
                                    else
                                    {
                                        DLog(LL_Debug, LD_CoreData, @"Sub-Object Creation Failed: %@", NSStringFromClass(cdoSubClass));
                                    }
                                }];
                           }
                       }];
                  }
              }
              else
              {
                  //DLog(LL_Debug, LD_General, @"loadRelateToOne: key=%@", key);
                  if (dict[key] && ![dict[key] isKindOfClass:[NSNull class]])
                  {
                      Class  cdoSubClass = NSClassFromString([NSString stringWithFormat:@"CDO%@", [relationship.destinationEntity name]]);
                      
                      id objD    = dict[key];
                      if ([objD isKindOfClass:[NSString class]])
                      {
                          objD   = @{ @"id" : objD };
                      }
                      
                      NSMutableDictionary*  objMD   = [objD mutableCopy];
                      objMD[@"_relationship"]       = key;
                      
                      [[cdoSubClass entityModel] performBlockAndWait:
                       ^(NSManagedObjectContext* context)
                       {
                           id     existingObject  = [self valueForKey:key];
                           id     newObject       = [cdoSubClass entityFromDictionary:objMD];
                           if (newObject)
                           {
                               BOOL   isEqual = NO;
                               
                               NSString*  equalityMethodName  = [NSString stringWithFormat:@"isEqualTo%@:", [relationship.destinationEntity name]];
                               SEL        equalitySelector    = NSSelectorFromString(equalityMethodName);
                               
                               //DLog(LL_Debug, LD_CoreData, @"Trace Point [%@] sub=%@", NSStringFromClass([self class]), NSStringFromClass([newObject class]));
                               if ([existingObject respondsToSelector:equalitySelector])
                               {
                                   NSInvocation*  inv = [NSInvocation invocationWithTarget:existingObject
                                                                                  selector:equalitySelector];
                                   [inv setArgument:&newObject atIndex:2];
                                   [inv invoke];
                                   [inv getReturnValue:&isEqual];
                               }
                               
                               if (!isEqual)
                               {
                                   [self setValue:newObject forKey:key];
                               }
                           }
                           else
                           {
                               DLog(LL_Debug, LD_CoreData, @"Sub-Object Creation Failed: %@", NSStringFromClass(cdoSubClass));
                           }
                       }];
                  }
              }
          }];
     }];
}

- (NSDictionary*)saveToDictionary
{
    NSDictionary*           attributes  = [self.entity attributesByName];
    NSMutableDictionary*    dict        = [NSMutableDictionary dictionary];

    NSDictionary*           newDict     = [self saveIDToDictionary];
    if (newDict)
    {
        dict    = [newDict mutableCopy];
    }

    [attributes enumerateKeysAndObjectsUsingBlock:
     ^(id key, NSAttributeDescription* attribute, BOOL* stop)
     {
         if (![key isKindOfClass:[NSString class]])
         {
             DLog(LL_Debug, LD_General, @"save: NOTSTRING key=%@", key);
             return;
         }

         if ([key isEqualToString:[[self class] idAttribute]])
         {
             //DLog(LL_Debug, LD_General, @"save: ID key=%@", key);
             return;
         }

         //DLog(LL_Debug, LD_General, @"save: key=%@", key);
         id currentValue    = [self valueForKey:key];

         if (currentValue)
         {
             switch (attribute.attributeType)
             {
                 case NSInteger16AttributeType:
                 case NSInteger32AttributeType:
                 case NSInteger64AttributeType:
                 case NSBooleanAttributeType:
                 case NSDecimalAttributeType:
                 case NSDoubleAttributeType:
                 case NSFloatAttributeType:
                 case NSStringAttributeType:
                 {
                     dict[key]  = currentValue;
                     break;
                 }

                 case NSDateAttributeType:
                 {
                     //DLog(LL_Debug, LD_General, @"load: updateDateFieldIfChanged");
                     if (currentValue && ![currentValue isEqual:[NSNull null]] && [currentValue isKindOfClass:[NSDate class]])
                     {
                         dict[key]  = @([currentValue unixTimestamp]);
                     }
                     break;
                 }
                     
                 case NSTransformableAttributeType:
                 {
                     dict[key]  = @([[currentValue date] unixTimestamp]);
                     break;
                 }
             }
         }
     }];

    BOOL    addedFaked = NO;

    NSString*   addedKey    = [[self class] addedAttribute];
    
    id    added = [self valueForKey:addedKey];
    if (!added)
    {
        if ([[attributes allKeys] containsObject:addedKey])
        {
            @try
            {
                [self setValue:[NSDate date] forKey:addedKey];
                addedFaked  = YES;
            }
            @catch (NSException *exception)
            {
                // TODO: respond to CoreData fault
            }
        }
    }

    NSDictionary*   relationships   = [self.entity relationshipsByName];

    [relationships enumerateKeysAndObjectsUsingBlock:^(id key, NSRelationshipDescription* relationship, BOOL* stop)
     {
         if (![key isKindOfClass:[NSString class]])
         {
             DLog(LL_Debug, LD_General, @"saveRelate: NOTSTRING key=%@", key);
             return;
         }

         if ([relationship isToMany])
         {
             //DLog(LL_Debug, LD_General, @"saveRelateToMany: key=%@", key);
             id currentValue    = [self valueForKey:key];

             dict[key]  = [NSMutableArray arrayWithCapacity:[currentValue count]];
             [currentValue enumerateObjectsUsingBlock:
              ^(DNManagedObject* obj, NSUInteger idx, BOOL* stop)
              {
                  id    newObject;

                  id    added       = [obj valueForKey:addedKey];
                  if (!added)
                  {
                      [obj setValue:[NSDate date] forKey:addedKey];
                      newObject   = [obj saveToDictionary];
                      [obj setValue:nil forKey:addedKey];
                  }
                  else
                  {
                      newObject   = [obj saveIDToDictionary];
                  }
                  if (newObject)
                  {
                      [dict[key] addObject:newObject];
                  }
              }];
         }
         else
         {
             //DLog(LL_Debug, LD_General, @"saveRelateToOne: key=%@", key);
             id currentValue    = [self valueForKey:key];

             if (currentValue)
             {
                 id    newObject;

                 id    added       = [currentValue valueForKey:addedKey];
                 if (!added)
                 {
                     [currentValue setValue:[NSDate date] forKey:addedKey];
                     newObject   = [currentValue saveToDictionary];
                     [currentValue setValue:nil forKey:addedKey];
                 }
                 else
                 {
                     newObject   = [currentValue saveIDToDictionary];
                 }
                 if (newObject)
                 {
                     dict[key]  = newObject;
                 }
             }
         }
     }];

    if (addedFaked)
    {
        [self setValue:nil forKey:addedKey];
    }

    return dict;
}

- (NSDictionary*)saveIDToDictionary
{
    if ([self.objectID isTemporaryID])
    {
        [self.managedObjectContext performBlockAndWait:
         ^()
         {
             NSError*   error;
             
             [self.managedObjectContext obtainPermanentIDsForObjects:@[ self ] error:&error];
         }];
    }
    if ([self.objectID isTemporaryID])
    {
        DLog(LL_Debug, LD_General, @"STILL temporary!");
    }
    
    id  idValue = [self valueForKey:[[self class] idAttribute]];
    if (!idValue || [idValue isEqual:[NSNull null]])
    {
        return nil;
    }

    return @{
             [[self class] idAttribute] : idValue,
             @"objectID"                : [[self.objectID URIRepresentation] absoluteString]
             };
}

#pragma mark - Entity save/delete functions

- (void)saveContext;
{
    [[self class] saveContext];
}

- (void)deleteWithNoSave
{
    [self performBlock:
     ^(NSManagedObjectContext* context)
     {
         [context deleteObject:self];
     }];
}

- (void)delete
{
    [self deleteWithNoSave];
    [self performBlock:
     ^(NSManagedObjectContext* context)
     {
         [context processPendingChanges];
     }];
    [self saveContext];
}

#pragma mark - Entity Description functions

- (NSEntityDescription*)entityDescription
{
    __block NSEntityDescription*    retval;

    retval = [NSEntityDescription entityForName:[[self class] entityName]
                         inManagedObjectContext:[[self class] managedObjectContext]];

    return retval;
}

#pragma mark - Update If Changed functions

- (NSNumber*)updateBooleanFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [self updateBooleanFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (NSNumber*)updateBooleanFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }

    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue)
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryBoolean:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue)
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryNumber:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue)
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryDecimalNumber:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue)
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryDouble:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue)
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryString:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue)
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryArray:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue)
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryDictionary:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue || ![localDefaultValue isKindOfClass:[NSDate class]])
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryDate:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
    {
        [self setValue:newValue forKeyPath:keypath];
    }

    return newValue;
}

- (DNDate*)updateDNDateFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(DNDate*)defaultValue
{
    return [self updateDNDateFieldIfChanged:keypath fromDictionary:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (DNDate*)updateDNDateFieldIfChanged:(NSString*)keypath fromDictionary:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(DNDate*)defaultValue
{
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue || ![localDefaultValue isKindOfClass:[DNDate class]])
    {
        localDefaultValue   = defaultValue;
    }
    
    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryDNDate:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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
    BOOL*   localDirtyFlag  = dirtyFlag;
    BOOL    defaultDirtyFlag;
    if (!localDirtyFlag)
    {
        localDirtyFlag  = &defaultDirtyFlag;
    }
    
    id  localDefaultValue   = [self valueForKeyPath:keypath];
    if (!localDefaultValue)
    {
        localDefaultValue   = defaultValue;
    }

    *localDirtyFlag  = NO;
    
    id  newValue = [self dictionaryObject:dictionary dirty:localDirtyFlag withItem:key andDefault:localDefaultValue];
    if (*localDirtyFlag)
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

- (DNDate*)dictionaryDNDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(DNDate*)defaultValue
{
    return [DNUtilities dictionaryDNDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

- (DNDate*)dictionaryDNDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(DNDate*)defaultValue
{
    return [DNUtilities dictionaryDNDate:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
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

+ (DNDate*)dictionaryDNDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(DNDate*)defaultValue
{
    return [DNUtilities dictionaryDNDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (DNDate*)dictionaryDNDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(DNDate*)defaultValue
{
    return [DNUtilities dictionaryDNDate:dictionary dirty:dirtyFlag withItem:key andDefault:defaultValue];
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
    [self performWithContext:[self managedObjectContext]
                blockAndWait:block];
}

- (void)performBlock:(void (^)(NSManagedObjectContext* context))block
{
    [self performWithContext:[self managedObjectContext]
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
