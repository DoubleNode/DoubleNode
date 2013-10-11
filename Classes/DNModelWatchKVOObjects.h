//
//  DNModelWatchKVOObjects.h
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNUtilities.h"

#import "DNModelWatchObjects.h"

#import "DNModel.h"
#import "DNManagedObject.h"

@interface DNModelWatchKVOObjects : DNModelWatchObjects

+ (id)watchWithModel:(DNModel*)model andObjects:(NSArray*)objects didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

- (id)initWithModel:(DNModel*)model andObjects:(NSArray*)objects didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler;

@end
