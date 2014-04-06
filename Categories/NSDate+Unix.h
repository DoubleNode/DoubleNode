//
//  NSDate+Unix.h
//
//  Created by Darren Ehlers on 2011.10.26.
//  Copyright 2011 Darren Ehlers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(Unix)

- (int)unixTimestamp;
- (NSComparisonResult)unixCompare:(NSDate*)time;

@end
