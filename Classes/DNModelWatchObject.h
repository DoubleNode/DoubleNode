//
//  DNModelWatchObject.h
//  Pods
//
//  Created by Darren Ehlers on 10/8/13.
//
//

#import "DNModelWatch.h"

@class DNManagedObject;
@class DNModelWatchObject;

typedef void(^DNModelWatchObjectWillChangeHandlerBlock)(DNModelWatchObject* watch, DNManagedObject* object);
typedef void(^DNModelWatchObjectDidChangeHandlerBlock)(DNModelWatchObject* watch, DNManagedObject* object);

@interface DNModelWatchObject : DNModelWatch

- (id)initWithModel:(DNModel*)model andHandler:(DNModelWatchObjectDidChangeHandlerBlock)handler;

- (DNManagedObject*)object;

@end
