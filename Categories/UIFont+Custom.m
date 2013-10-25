//
//  UIFont+Custom.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "UIFont+Custom.h"

@implementation UIFont(Custom)

+ (UIFont*)customFontWithName:(NSString*)fontName size:(double)fontSize
{
    UIFont* retval  = [UIFont fontWithName:fontName size:fontSize];
    return [retval fontWithSize:fontSize];
}

@end
