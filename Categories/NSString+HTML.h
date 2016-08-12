//
//  NSString+HTML.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

/**
 *  Creates and returns a new NSString object initialized with the source string, with XML entities replaced with their decoded values.  Current support includes: &amp;, &nbsp;, &apos;, &quot;, &lt;, &gt; and most numeric character representations.
 *
 *  @return A new NSString object, initialized with the source string, with XML entities replaced with their decoded values.
 */
- (NSString *)stringByDecodingXMLEntities;

@end
