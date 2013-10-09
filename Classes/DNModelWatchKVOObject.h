//
//  DNModelWatchKVOObject.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNUtilities.h"

#import "DNModelWatchObject.h"

#import "DNModel.h"
#import "DNManagedObject.h"

@interface DNModelWatchKVOObject : DNModelWatchObject

+ (id)watchWithModel:(DNModel*)model andObject:(DNManagedObject*)object andHandler:(DNModelWatchObjectDidChangeHandlerBlock)resultsHandler;

- (id)initWithModel:(DNModel*)model andObject:(DNManagedObject*)object andHandler:(DNModelWatchObjectDidChangeHandlerBlock)resultsHandler;

@end
