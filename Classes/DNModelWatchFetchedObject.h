//
//  DNModelWatchFetchedObject.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNUtilities.h"

#import "DNModelWatchObject.h"

#import "DNModel.h"

@interface DNModelWatchFetchedObject : DNModelWatchObject

+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch;

- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch;

@end
