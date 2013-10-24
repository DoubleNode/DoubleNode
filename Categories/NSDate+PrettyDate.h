//
//  NSDate+PrettyDate.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PrettyDate)

- (NSString*)prettyDate;
- (NSString*)prettyDateRange:(NSDate*)end;
- (NSString*)localizedDate;

@end
