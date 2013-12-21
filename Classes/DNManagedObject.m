//
//  DNManagedObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNManagedObject.h"

#import "DNModel.h"

#import "DNUtilities.h"
#import "NSString+HTML.h"

@implementation DNManagedObject

@dynamic id;

#pragma mark - Entity description functions

+ (Class)entityModelClass
{
    NSException*    exception = [NSException exceptionWithName:@"DMManagedObject Exception"
                                                        reason:@"Base entityModelClass: should never be called, override might be missing!"
                                                      userInfo: nil];
    @throw exception;

    // Not sure if this is ever reached
    return nil;
}

+ (DNModel*)entityModel
{
    return [[[[self class] entityModelClass] alloc] init];
}

+ (NSString*)entityName
{
    // Assume a 3-character prefix to class name and no suffix
    return [NSStringFromClass([self class]) substringFromIndex:3];
}

+ (id)entityIDWithDictionary:(NSDictionary*)dict
{
    return [[self class] dictionaryNumber:dict withItem:@"id" andDefault:nil];
}

- (void)loadWithDictionary:(NSDictionary*)dict
{
    
}

+ (NSDictionary*)attributesForRepresentation:(NSDictionary*)representation
                                    ofEntity:(NSEntityDescription*)entity
                                fromResponse:(NSHTTPURLResponse*)response
{
    return [[NSDictionary alloc] init];
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

+ (id<DNApplicationProtocol>)appDelegate
{
    return (id<DNApplicationProtocol>)[[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext*)managedObjectContext
{
    return [[[self class] appDelegate] managedObjectContext:[[self class] entityModelClass]];
}

+ (NSManagedObjectModel*)managedObjectModel
{
    return [[[self class] appDelegate] managedObjectModel:[[self class] entityModelClass]];
}

+ (void)saveContext
{
    [[[self class] appDelegate] saveContext:[[self class] entityModelClass]];
}

- (void)setId:(id)idValue
{
    [self setValue:idValue forKey:@"id"];
}

#pragma mark - Entity initialization functions

+ (instancetype)entity
{
    return [[self alloc] init];
}

+ (instancetype)entityFromDictionary:(NSDictionary*)dict
{
    return [[self alloc] initWithDictionary:dict];
}

+ (instancetype)entityFromID:(id)idValue
{
    return [[self alloc] initWithID:idValue];
}

- (instancetype)init
{
    managedObjectContext    = [[self class] managedObjectContext];
    
    NSEntityDescription*    entity = [NSEntityDescription entityForName:[[self class] entityName] inManagedObjectContext:managedObjectContext];
    
    self = [self initWithEntity:entity insertIntoManagedObjectContext:[[self class] managedObjectContext]];
    if (self)
    {
        [self clearData];
    }
    
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

#pragma mark - Entity save/delete functions

- (void)saveContext;
{
    [[self class] saveContext];
}

- (void)deleteWithNoSave
{
    [[[self class] managedObjectContext] deleteObject:self];
}

- (void)delete
{
    [self deleteWithNoSave];
    [self saveContext];
}

#pragma mark - Entity Description functions

- (NSEntityDescription*)entityDescription
{
    return [NSEntityDescription entityForName:[[self class] entityName]
                       inManagedObjectContext:[[self class] managedObjectContext]];
}

#pragma mark - Dictionary Translation functions

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryNumber:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSString*)[NSNull null])
        {
            NSNumber*   newval  = [NSNumber numberWithInt:[object intValue]];
            
            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    
    return retval;
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    return [[self class] dictionaryDouble:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSString*)[NSNull null])
        {
            NSNumber*   newval  = [NSNumber numberWithDouble:[object doubleValue]];
            
            if ((retval == nil) || ([newval isEqualToNumber:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    
    return retval;
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    return [[self class] dictionaryString:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    NSString*   retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if ([object isKindOfClass:[NSArray class]] == YES)
        {
            if (object != (NSArray*)[NSNull null])
            {
                if ([object count] > 0)
                {
                    NSString*   newval  = object[0];
                    
                    if ((retval == nil) || ([newval isEqualToString:retval] == NO))
                    {
                        if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                        retval = newval;
                    }
                }
            }
        }
        else
        {
            if ([object isKindOfClass:[NSString class]] == YES)
            {
                if ([object isEqualToString:@"<null>"] == YES)
                {
                    object  = @"";
                }
            }
            else
            {
                object = [object stringValue];
            }
            if (object != (NSString*)[NSNull null])
            {
                NSString*   newval  = object;
                
                if ((retval == nil) || ([newval isEqualToString:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }
    
    return [retval stringByDecodingXMLEntities];
}

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    return [[self class] dictionaryArray:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue
{
    NSArray*    retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSArray*)[NSNull null])
        {
            if ([object isKindOfClass:[NSArray class]] == YES)
            {
                NSArray*   newval  = object;
                
                if ((retval == nil) || ([newval isEqualToArray:retval] == NO))
                {
                    if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                    retval = newval;
                }
            }
        }
    }
    
    return retval;
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    return [[self class] dictionaryDate:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate*   retval  = defaultValue;
    
    id  object = [dictionary objectForKey:key];
    if (object != nil)
    {
        if (object != (NSString*)[NSNull null])
        {
            NSDate*   newval  = [dateFormatter dateFromString:object];
            
            if ((retval == nil) || ([newval isEqualToDate:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    
    return retval;
}

+ (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue
{
    return [[self class] dictionaryObject:dictionary dirty:nil withItem:key andDefault:defaultValue];
}

+ (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue
{
    id  retval  = defaultValue;
    
    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (id)[NSNull null])
        {
            id  newval  = dictionary[key];
            
            if ((retval == nil) || ([newval isEqual:retval] == NO))
            {
                if (dirtyFlag != nil)   {   *dirtyFlag = YES;   }
                retval = newval;
            }
        }
    }
    
    return retval;
}

@end
