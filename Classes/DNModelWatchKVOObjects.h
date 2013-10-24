//
//  DNModelWatchKVOObjects.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNUtilities.h"

#import "DNModelWatchObjects.h"

#import "DNModel.h"
#import "DNManagedObject.h"

@interface DNModelWatchKVOObjects : DNModelWatchObjects

+ (id)watchWithModel:(DNModel*)model
          andObjects:(NSArray*)objects
           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

+ (id)watchWithModel:(DNModel*)model
          andObjects:(NSArray*)objects
       andAttributes:(NSArray*)attributes
           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)objects
          didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)objects
      andAttributes:(NSArray*)attributes
          didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

@end
