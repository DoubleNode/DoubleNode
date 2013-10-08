//
//  DNModelWatchObject.h
//  Pods
//
//  Created by Darren Ehlers on 10/8/13.
//
//

#import "DNModelWatch.h"

#import "DNManagedObject.h"

@class DNModelWatchObject;

typedef void(^DNModelWatchObject_resultsHandlerBlock)(DNModelWatchObjects* watch, DNManagedObject* object);

@interface DNModelWatchObject : DNModelWatch

- (DNManagedObject*)object;

@end
