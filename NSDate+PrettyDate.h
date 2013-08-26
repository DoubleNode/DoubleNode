//
//  NSDate+PrettyDate.h
//  MZ Proto
//
//  Created by Darren Ehlers on 12/14/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PrettyDate)

- (NSString*)prettyDate;
- (NSString*)prettyDateRange:(NSDate*)end;
- (NSString*)localizedDate;

@end
