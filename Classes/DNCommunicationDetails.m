//
//  DNCommunicationDetails.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNCommunicationDetails.h"

@implementation DNCommunicationDetails

+ (id)details
{
    return [[[self class] alloc] init];
}

- (NSString*)path
{
    return self.router.path;
}

- (NSURL*)URL
{
    return self.router.URL;
}


@end
