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

typedef void(^getFromID_resultsHandlerBlock)(id entity);
typedef void(^getAll_resultsHandlerBlock)(NSArray* entities);

@interface DNModel : NSObject

+ (NSString*)entityName;

- (id)init;

- (NSString*)getFromIDFetchTemplate;
- (NSString*)getAllFetchTemplate;
- (NSArray*)getAllSortKeys;

- (void)getFromID:(id)idValue onResult:(getFromID_resultsHandlerBlock)resultsHandler;

- (void)getAllRefetchData;
- (void)getAllOnResult:(getAll_resultsHandlerBlock)resultsHandler;

- (void)deleteAll;

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller;

@end
