//
//  DNModelWatchObjects.h
//  Pods
//
//  Created by Darren Ehlers on 10/8/13.
//
//

#import "DNModelWatch.h"

@class DNModelWatchObjects;

typedef void(^DNModelWatchObjects_resultsHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects);

@interface DNModelWatchObjects : DNModelWatch

- (id)initWithModel:(DNModel*)model andHandler:(DNModelWatchObjects_resultsHandlerBlock)handler;

- (NSArray*)objects;

@end
