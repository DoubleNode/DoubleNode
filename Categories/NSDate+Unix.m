//
//  NSDate+Unix.m
//
//  Created by Darren Ehlers on 2011.10.26.
//  Copyright 2011 Darren Ehlers. All rights reserved.
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
