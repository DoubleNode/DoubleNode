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
#import "DNModelWatchFetchedObject.h"
#import "DNModelWatchFetchedObjects.h"

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
- (NSArray*)getFromIDSortKeys;
- (NSArray*)getAllSortKeys;

- (DNModelWatchObject*)watchObject:(DNManagedObject*)object
                          onResult:(DNModelWatchObjectDidChangeHandlerBlock)handler;
- (DNModelWatchObjects*)watchObjects:(NSArray*)objects
                            onResult:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (void)retainWatch:(DNModelWatch*)watch;
- (void)releaseWatch:(DNModelWatch*)watch;

- (DNModelWatchObject*)getFromID:(id)idValue onResult:(DNModelWatchObjectDidChangeHandlerBlock)handler;

- (DNModelWatchObjects*)getAllOnResult:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (void)deleteAll;

@end
