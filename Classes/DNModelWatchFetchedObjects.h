//
//  DNModelWatchFetchedObjects.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNUtilities.h"

#import "DNModelWatchObjects.h"

#import "DNModel.h"

@interface DNModelWatchFetchedObjects : DNModelWatchObjects

+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch andHandler:(DNModelWatchObjects_resultsHandlerBlock)resultsHandler;

- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch andHandler:(DNModelWatchObjects_resultsHandlerBlock)resultsHandler;

@end
