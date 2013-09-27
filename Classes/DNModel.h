//
//  DNModel.h
//  Pods
//
//  Created by Darren Ehlers on 9/27/13.
//
//

#import <Foundation/Foundation.h>

#import "DNUtilities.h"

typedef void(^getAll_resultsHandlerBlock)(NSArray*);

@interface DNModel : NSObject

- (NSString*)getAllFetchTemplate;
- (NSArray*)getAllSortKeys;

- (void)getAllRefetchData;
- (void)getAllOnResult:(getAll_resultsHandlerBlock)resultsHandler;

- (void)deleteAll;

@end
