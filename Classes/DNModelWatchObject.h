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

typedef void(^DNModelWatchObject_resultsHandlerBlock)(DNModelWatchObject* watch, DNManagedObject* object);

@interface DNModelWatchObject : DNModelWatch

- (id)initWithModel:(DNModel*)model andHandler:(DNModelWatchObject_resultsHandlerBlock)handler;

- (DNManagedObject*)object;

@end
