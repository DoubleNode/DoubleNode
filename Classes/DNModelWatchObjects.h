//
//  DNModelWatchObjects.h
//  Pods
//
//  Created by Darren Ehlers on 10/8/13.
//
//

#import "DNModelWatch.h"

@class DNModelWatchObjects;

typedef void(^DNModelWatchObjectsWillChangeHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects);
typedef void(^DNModelWatchObjectsDidChangeHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects);

@interface DNModelWatchObjects : DNModelWatch

- (id)initWithModel:(DNModel*)model didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (NSArray*)objects;

@end
