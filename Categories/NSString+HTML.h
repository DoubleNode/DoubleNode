//
//  NSString+HTML.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString *)stringByDecodingXMLEntities;

@end