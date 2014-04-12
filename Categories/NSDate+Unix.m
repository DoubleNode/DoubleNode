//
//  NSDate+Unix.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "NSDate+Unix.h"

@implementation NSDate(Unix)

- (int)unixTimestamp
{
    return (int)[self timeIntervalSince1970];
}

- (NSComparisonResult)unixCompare:(NSDate*)timeval
{
    NSDate* timestamp1 = [NSDate dateWithTimeIntervalSince1970:[self unixTimestamp]];
    NSDate* timestamp2 = [NSDate dateWithTimeIntervalSince1970:[timeval unixTimestamp]];
    return [timestamp1 compare:timestamp2];
}

@end
