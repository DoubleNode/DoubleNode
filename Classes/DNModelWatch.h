//
//  DNModelWatch.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNUtilities.h"

@class DNModel;

@interface DNModelWatch : NSObject

- (id)initWithModel:(DNModel*)model;

- (BOOL)checkWatch;
- (void)cancelWatch;
- (void)refreshWatch;

- (void)executeWillChangeHandler;
- (void)executeDidChangeHandler;

@end
