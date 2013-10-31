//
//  UIFont+Custom.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Custom)

/**
 *  Creates and returns a new UIFont object (works around the iOS oddity which required an additional sizing call).
 *
 *  @param fontName The postscript font name string
 *  @param fontSize The font size (in points)
 *
 *  @return A new UIFont configured according to the specified parameters.
 */
+ (UIFont*)customFontWithName:(NSString*)fontName size:(double)fontSize;

@end
