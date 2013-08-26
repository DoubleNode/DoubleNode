//
//  DNManagedObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DNManagedObject : NSManagedObject    // <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain)   NSNumber*       id;
//@property (nonatomic, strong)   SCCustomCell*   customCell;

//+ (SCClassDefinition*)classDef;
+ (NSManagedObjectContext*)managedObjectContext;
+ (NSManagedObjectModel*)managedObjectModel;

+ (BOOL)saveContext;
+ (NSArray*)getAll;
+ (BOOL)deleteAll;

+ (NSNumber*)dictionaryBoolean:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue;
+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
+ (NSDictionary*)dictionaryDictionary:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDictionary*)defaultValue;

- (id)save;
- (void)delete;

@end
