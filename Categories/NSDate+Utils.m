//
//  NSDate+Utils
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (NSDate*)toLocalTime
{
    NSTimeZone* tz      = [NSTimeZone localTimeZone];
    NSInteger   seconds = [tz secondsFromGMTForDate:self];
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

- (NSDate*)toGlobalTime
{
    NSTimeZone* tz      = [NSTimeZone localTimeZone];
    NSInteger   seconds = -[tz secondsFromGMTForDate:self];
    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

@end
