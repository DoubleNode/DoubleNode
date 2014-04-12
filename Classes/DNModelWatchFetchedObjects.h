//
//  DNModelWatchFetchedObjects.h
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

@interface DNModelWatchFetchedObjects : DNModelWatchObjects

+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch;

- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch;

@end
