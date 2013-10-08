//
//  DNModelWatch_getAll.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNUtilities.h"
#import "DNModelWatch.h"

typedef void(^getAll_resultsHandlerBlock)(DNModelWatch* watch, NSArray* entities);

@interface DNModelWatch_getAll : DNModelWatch

+ (id)watchWithFetch:(NSFetchRequest*)fetch andHandler:(getAll_resultsHandlerBlock)resultsHandler;

- (id)initWithFetch:(NSFetchRequest*)fetch andHandler:(getAll_resultsHandlerBlock)resultsHandler;

- (void)cancelFetch;

- (void)executeResultsHandler:(NSArray*)entities;

@end
