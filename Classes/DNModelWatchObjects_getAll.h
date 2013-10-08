//
//  DNModelWatchObjects_getAll.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNUtilities.h"

#import "DNModelWatchObjects.h"

@interface DNModelWatchObjects_getAll : DNModelWatchObjects

+ (id)watchWithFetch:(NSFetchRequest*)fetch andHandler:(DNModelWatchObjects_resultsHandlerBlock)resultsHandler;

- (id)initWithFetch:(NSFetchRequest*)fetch andHandler:(DNModelWatchObjects_resultsHandlerBlock)resultsHandler;

@end
