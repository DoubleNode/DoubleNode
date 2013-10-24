//
//  DNModelWatchKVOObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
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
