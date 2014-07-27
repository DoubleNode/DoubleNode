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

typedef void(^DNModelWatchObjectWillChangeHandlerBlock)(DNModelWatchObject* watch, id object, NSDictionary* context);

typedef void(^DNModelWatchObjectDidChangeObjectInsertHandlerBlock)(DNModelWatchObject* watch, id object, NSDictionary* context);
typedef void(^DNModelWatchObjectDidChangeObjectDeleteHandlerBlock)(DNModelWatchObject* watch, id object, NSDictionary* context);
typedef void(^DNModelWatchObjectDidChangeObjectUpdateHandlerBlock)(DNModelWatchObject* watch, id object, NSDictionary* context);
typedef void(^DNModelWatchObjectDidChangeObjectMoveHandlerBlock)(DNModelWatchObject* watch, id object, NSDictionary* context);

typedef void(^DNModelWatchObjectDidChangeHandlerBlock)(DNModelWatchObject* watch, id object, NSDictionary* context);

@interface DNModelWatchObject : DNModelWatch

@property (strong, nonatomic) DNModelWatchObjectWillChangeHandlerBlock  willChangeHandler;

@property (strong, nonatomic) DNModelWatchObjectDidChangeObjectInsertHandlerBlock   didChangeObjectInsertHandler;
@property (strong, nonatomic) DNModelWatchObjectDidChangeObjectDeleteHandlerBlock   didChangeObjectDeleteHandler;
@property (strong, nonatomic) DNModelWatchObjectDidChangeObjectUpdateHandlerBlock   didChangeObjectUpdateHandler;
@property (strong, nonatomic) DNModelWatchObjectDidChangeObjectMoveHandlerBlock     didChangeObjectMoveHandler;

@property (strong, nonatomic) DNModelWatchObjectDidChangeHandlerBlock   didChangeHandler;

- (id)initWithModel:(DNModel*)model;

- (DNManagedObject*)object;

@end
