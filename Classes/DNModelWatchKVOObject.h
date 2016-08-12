//
//  DNModelWatchKVOObject.h
//  DoubleNode.com
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
           andObject:(DNManagedObject*)object;

+ (id)watchWithModel:(DNModel*)model
           andObject:(DNManagedObject*)object
       andAttributes:(NSArray*)attributes;

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)object;

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)object
      andAttributes:(NSArray*)attributes;

@end
