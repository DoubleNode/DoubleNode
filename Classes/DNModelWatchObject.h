//
//  DNModelWatchObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNModelWatch.h"

@class DNManagedObject;
@class DNModelWatchObject;

typedef void(^DNModelWatchObjectWillChangeHandlerBlock)(DNModelWatchObject* watch, id object);
typedef void(^DNModelWatchObjectDidChangeHandlerBlock)(DNModelWatchObject* watch, id object);

@interface DNModelWatchObject : DNModelWatch

- (id)initWithModel:(DNModel*)model didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;

- (DNManagedObject*)object;

@end
