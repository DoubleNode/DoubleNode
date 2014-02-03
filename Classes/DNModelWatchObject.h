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

@property (strong, nonatomic) DNModelWatchObjectWillChangeHandlerBlock  willChangeHandler;
@property (strong, nonatomic) DNModelWatchObjectDidChangeHandlerBlock   didChangeHandler;

- (id)initWithModel:(DNModel*)model;

- (DNManagedObject*)object;

@end
