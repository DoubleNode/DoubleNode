//
//  NSAttributedString+StringFromHTML.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//
//  Derived from work originally created by
//  Created by Orta on 06/08/2013.
//  Copyright (c) 2013 Art.sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (StringFromHTML)

+ (NSAttributedString*)attributedStringWithTextParams:(NSDictionary*)textParams
                                              andHTML:(NSString *)HTML;

@end
