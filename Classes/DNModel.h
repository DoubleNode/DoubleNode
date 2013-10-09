//
//  DNModel.h
//  Pods
//
//  Created by Darren Ehlers on 9/27/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNUtilities.h"

#import "DNManagedObject.h"
#import "DNModelWatchObject.h"
#import "DNModelWatchObjects_getAll.h"

typedef void(^getFromID_resultsHandlerBlock)(id entity);

@interface DNModel : NSObject

+ (NSString*)entityName;

#pragma mark - AppDelegate access functions

+ (id<DNApplicationDelegate>)appDelegate;
+ (NSManagedObjectContext*)managedObjectContext;
+ (NSManagedObjectModel*)managedObjectModel;
+ (void)saveContext;

+ (instancetype)model;

- (id)init;

- (void)saveContext;

- (NSString*)getFromIDFetchTemplate;
- (NSString*)getAllFetchTemplate;
- (NSArray*)getAllSortKeys;

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                          onResult:(DNModelWatchObject_resultsHandlerBlock)resultHandler;

- (void)retainWatch:(DNModelWatch*)watch;
- (void)releaseWatch:(DNModelWatch*)watch;

- (void)getFromID:(id)idValue onResult:(getFromID_resultsHandlerBlock)resultsHandler;

- (DNModelWatchObjects*)getAllOnResult:(DNModelWatchObjects_resultsHandlerBlock)resultsHandler;

- (void)deleteAll;

@end
