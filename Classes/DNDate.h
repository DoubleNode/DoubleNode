//
//  DNDate.h
//  MADStudios
//
//  Created by Darren Ehlers on 11/16/14.
//  Copyright (c) 2014 DoubleNode. All rights reserved.
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

- (NSDate*)date;

@end
