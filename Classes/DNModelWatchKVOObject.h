//
//  DNModelWatchKVOObject.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNUtilities.h"

#import "DNModelWatchObject.h"

#import "DNModel.h"
#import "DNManagedObject.h"

@interface DNModelWatchKVOObject : DNModelWatchObject

+ (id)watchWithModel:(DNModel*)model
           andObject:(DNManagedObject*)object
           didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;

+ (id)watchWithModel:(DNModel*)model
           andObject:(DNManagedObject*)object
       andAttributes:(NSArray*)attributes
           didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)object
          didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)object
      andAttributes:(NSArray*)attributes
          didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler;

@end
