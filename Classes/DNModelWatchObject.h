//
//  DNModelWatchObject.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNModelWatch.h"

@class DNManagedObject;
@class DNModelWatchObject;

typedef void(^DNModelWatchObjectWillChangeHandlerBlock)(DNModelWatchObject* watch, id object);
typedef void(^DNModelWatchObjectDidChangeHandlerBlock)(DNModelWatchObject* watch, id object);

@interface DNModelWatchObject : DNModelWatch

@property (strong, nonatomic) DNModelWatchObjectWillChangeHandlerBlock  willChangeHandler;
@property (strong, nonatomic) DNModelWatchObjectDidChangeHandlerBlock   didChangeHandler;

- (id)initWithModel:(DNModel*)model;

- (DNManagedObject*)object;

@end
