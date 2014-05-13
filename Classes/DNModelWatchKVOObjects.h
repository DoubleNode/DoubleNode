//
//  DNModelWatchKVOObjects.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNUtilities.h"

#import "DNModelWatchObjects.h"

#import "DNModel.h"
#import "DNManagedObject.h"

@interface DNModelWatchKVOObjects : DNModelWatchObjects

+ (id)watchWithModel:(DNModel*)model
          andObjects:(NSArray*)objects;

+ (id)watchWithModel:(DNModel*)model
          andObjects:(NSArray*)objects
       andAttributes:(NSArray*)attributes;

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)objects;

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)objects
      andAttributes:(NSArray*)attributes;

@end
