//
//  DNManagedObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNManagedObject.h"

#import "MZPMunzeeAPI.h"
#import "MZPAppDelegate.h"

@implementation DNManagedObject

@dynamic id;

@synthesize customCell;

+ (SCClassDefinition*)classDef
{
    return nil;
}

+ (NSManagedObjectContext*)managedObjectContext
{
    return [MZPAppDelegate appDelegate].managedObjectContext;
}

+ (NSManagedObjectModel*)managedObjectModel
{
    return MZPAppDelegate.appDelegate.managedObjectModel;
}

+ (BOOL)saveContext
{
    return [[MZPAppDelegate appDelegate] saveContext];
}

+ (NSArray*)getAll
{
    return nil;
}

+ (BOOL)deleteAll
{
    NSArray*    all = [self getAll];
    if ([all count] > 0)
    {
        [all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             [obj deleteWithNoSave];
         }];
        
        [self saveContext];
    }
    
    return YES;
}

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;
    
    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (NSString*)[NSNull null])
        {
            retval = [NSNumber numberWithBool:[dictionary[key] boolValue]];
        }
    }
    
    return retval;
}

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;
    
    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (NSString*)[NSNull null])
        {
            retval = [NSNumber numberWithLongLong:[dictionary[key] longLongValue]];
        }
    }
    
    return retval;
}

+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue
{
    NSNumber*   retval  = defaultValue;
    
    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (NSString*)[NSNull null])
        {
            retval = [NSNumber numberWithDouble:[dictionary[key] doubleValue]];
        }
    }
    
    return retval;
}

+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue
{
    NSString*   retval  = defaultValue;
    
    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (NSString*)[NSNull null])
        {
            retval = dictionary[key];
        }
    }
    
    return retval;
}

+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate*   retval  = defaultValue;
    
    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (NSString*)[NSNull null])
        {
            retval = [dateFormatter dateFromString:dictionary[key]];
        }
    }
    
    return retval;
}

+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue
{
    NSDictionary*   retval  = defaultValue;
    
    if ([dictionary objectForKey:key] != nil)
    {
        if (dictionary[key] != (NSDictionary*)[NSNull null])
        {
            retval = dictionary[key];
        }
    }
    
    return retval;
}

- (id)save;
{
    [[self class] saveContext];
    return self;
}

- (void)deleteWithNoSave
{
    [MZPAppDelegate runOnMainThreadWithoutDeadlocking:^
     {
         [[[self class] managedObjectContext] deleteObject:self];
         [self save];
     }];
}

- (void)delete
{
    [self deleteWithNoSave];
    [self save];
}

@end
