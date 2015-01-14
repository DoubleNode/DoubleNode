//
//  CDTestDataModel.m
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "CDTestDataModel.h"

@implementation CDTestDataModel

+ (id)dataModel
{
    static id               dataModel = nil;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^
                  {
                      // Create and return the theme:
                      dataModel = [[[self class] alloc] init];
                  });

    return dataModel;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }

    return self;
}

@end
