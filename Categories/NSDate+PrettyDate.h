//
//  NSDate+PrettyDate.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PrettyDate)

/**
 *  Creates and returns a new NSString object initialized with a natural language version of the source date in relation to now.
 *
 *  @warning This function is NOT localized, only supports English.
 *
 *  @return A new NSString object, configured with a natual language representation of the source date.
 */
- (NSString*)prettyDate;

/**
 *  Creates and returns a new NSString object initialized with a simple display of a date range, between the source date and the end data parameter.
 *
 *  @param end The end date for the date range string.
 *
 *  @warning This function is currently not very robust, and works well only for dates within the same month.  This function should be revisited and expanded upon in the future.
 *
 *  @return A new NSString object, configured with a simple representation of a date range (ie: MMM d-d, yyyy).
 */
- (NSString*)simpleDateRange:(NSDate*)end;

/**
 *  Creates an returns a new NSString object initialized with a localized version of the source date.
 *
 *  @return A new NSString object, configured with a localized version of the source date.
 */
- (NSString*)localizedDate;

@end
