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

typedef void(^DNModelWatchObjectWillChangeHandlerBlock)(DNModelWatchObject* watch, id object);
typedef void(^DNModelWatchObjectDidChangeHandlerBlock)(DNModelWatchObject* watch, id object);

@interface DNModelWatchObject : DNModelWatch

- (id)initWithModel:(DNModel*)model didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;

- (DNManagedObject*)object;

@end
