//
//  DNModelWatchFetchedObject.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNUtilities.h"

#import "DNModelWatchObject.h"

#import "DNModel.h"

@interface DNModelWatchFetchedObject : DNModelWatchObject

+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch andHandler:(DNModelWatchObjectDidChangeHandlerBlock)resultsHandler;

- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch andHandler:(DNModelWatchObjectDidChangeHandlerBlock)resultsHandler;

@end
