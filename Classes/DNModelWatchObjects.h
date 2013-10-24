//
//  DNModelWatchObjects.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNModelWatch.h"

@class DNModelWatchObjects;

typedef void(^DNModelWatchObjectsWillChangeHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects);
typedef void(^DNModelWatchObjectsDidChangeHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects);

@interface DNModelWatchObjects : DNModelWatch

- (id)initWithModel:(DNModel*)model didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (NSArray*)objects;

@end
