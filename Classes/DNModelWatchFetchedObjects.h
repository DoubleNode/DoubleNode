//
//  DNModelWatchFetchedObjects.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNUtilities.h"

#import "DNModelWatchObjects.h"

#import "DNModel.h"

@interface DNModelWatchFetchedObjects : DNModelWatchObjects

+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch;

- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch;

@end
