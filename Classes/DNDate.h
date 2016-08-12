//
//  DNDate.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNDate : NSDateComponents

+ (id)dateWithComponentFlags:(unsigned)flags fromDate:(NSDate*)date;
+ (id)dateWithComponents:(NSDateComponents*)components;

- (id)initWithComponentFlags:(unsigned)flags fromDate:(NSDate*)date;
- (id)initWithComponents:(NSDateComponents*)components;

- (id)initWithCoder:(NSCoder*)decoder;
- (void)encodeWithCoder:(NSCoder*)encoder;

- (NSComparisonResult)compare:(id)otherObject;
- (BOOL)isEqualToDNDate:(DNDate*)otherDate;

- (NSDate*)date;

- (NSString*)dayOfWeekString;
- (NSString*)dateString;
- (NSString*)timeString;

@end
