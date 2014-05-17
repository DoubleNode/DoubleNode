//
//  NSDate+MidnightUTC.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "NSDate+MidnightUTC.h"

@implementation NSDate (MidnightUTC)

- (NSDate*)midnightUTC
{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                   fromDate:self];
    //[dateComponents setHour:0];
    //[dateComponents setMinute:0];
    //[dateComponents setSecond:0];

    NSDate* midnightUTC = [calendar dateFromComponents:dateComponents];
    [calendar release];

    return midnightUTC;
}

@end
