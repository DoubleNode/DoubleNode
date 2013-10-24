//
//  DNModelWatchFetchedObject.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNUtilities.h"

#import "DNModelWatchObject.h"

#import "DNModel.h"

@interface DNModelWatchFetchedObject : DNModelWatchObject

+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch didChange:(DNModelWatchObjectDidChangeHandlerBlock)resultsHandler;

- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch didChange:(DNModelWatchObjectDidChangeHandlerBlock)resultsHandler;

@end
