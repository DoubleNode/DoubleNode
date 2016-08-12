//
//  NSDate+MidnightUTC.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MidnightUTC)

/**
 *  Creates and returns a new NSDate object initialized at midnight UTC on the source date.
 *
 *  @return A new NSDate object, configured with midnight UTC of the source date.
 */
- (NSDate*)midnightUTC;

/**
 *  Creates and returns a new NSDate object initialized at midnight (current timezone) on the source date.
 *
 *  @return A new NSDate object, configured with midnight (current timezone) of the source date.
 */
- (NSDate*)midnight;

@end
