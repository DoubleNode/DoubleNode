//
//  DNManagedObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNApplicationDelegate.h"

@interface DNManagedObject : NSManagedObject
{
    NSFetchedResultsController* fetchedResultsController;
    NSManagedObjectContext*     managedObjectContext;
}

@property (nonatomic, retain)   NSNumber*   id;

+ (NSString*)entityName;
+ (NSString*)getAll_TemplateName;
+ (NSArray*)getAll_SortKeys;
+ (NSString*)getFromId_KeyName;
+ (NSString*)getFromId_TemplateName;

+ (NSDictionary*)attributesForRepresentation:(NSDictionary*)representation
                                    ofEntity:(NSEntityDescription*)entity
                                fromResponse:(NSHTTPURLResponse*)response;

+ (id<DNApplicationDelegate>)appDelegate;
+ (NSManagedObjectContext*)managedObjectContext;
+ (NSManagedObjectModel*)managedObjectModel;

+ (void)saveContext;
+ (NSArray*)getAll;
+ (BOOL)deleteAll;

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSString*)dictionaryString:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSString*)defaultValue;
+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
+ (id)dictionaryObject:(NSDictionary*)dictionary withItem:(NSString*)key andDefault:(id)defaultValue;

+ (NSNumber*)dictionaryNumber:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSNumber*)dictionaryDouble:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSNumber*)defaultValue;
+ (NSString*)dictionaryString:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSString*)defaultValue;
+ (NSArray*)dictionaryArray:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSArray*)defaultValue;
+ (NSDate*)dictionaryDate:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(NSDate*)defaultValue;
+ (id)dictionaryObject:(NSDictionary*)dictionary dirty:(BOOL*)dirtyFlag withItem:(NSString*)key andDefault:(id)defaultValue;

+ (instancetype)getFromId:(NSNumber*)id;

- (instancetype)init;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
- (instancetype)initWithDictionary:(NSDictionary*)dict dirty:(BOOL*)dirtyFlag;

- (void)clearData;
- (void)loadWithDictionary:(NSDictionary*)dict;
- (void)loadWithDictionary:(NSDictionary*)dict dirty:(BOOL*)dirtyFlag;

- (instancetype)save;
- (void)deleteWithNoSave;
- (void)delete;

@end
