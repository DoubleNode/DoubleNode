//
//  UIFont+Custom.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "UIFont+Custom.h"

@implementation UIFont(Custom)

+ (UIFont*)customFontWithName:(NSString*)fontName size:(double)fontSize
{
    UIFont* retval  = [UIFont fontWithName:fontName size:fontSize];
    if (!retval)
    {
        NSArray*    fontFamilies = [UIFont familyNames];
        [fontFamilies enumerateObjectsUsingBlock:^(NSString* fontFamily, NSUInteger idx, BOOL* stop)
         {
             NSArray*   fontNames = [UIFont fontNamesForFamilyName:fontFamily];
             [fontNames enumerateObjectsUsingBlock:^(NSString* fontName, NSUInteger idx, BOOL* stop)
              {
                  NSLog (@"%@: %@", fontFamily, fontName);
              }];
         }];

        UIFontDescriptor*   fontDescriptor  = [UIFontDescriptor fontDescriptorWithName:fontName size:fontSize];
        NSLog (@"fontDescriptor: %@", fontDescriptor);

        UIFont* font    = [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
        NSLog (@"font: %@", font);
    }

    return [retval fontWithSize:fontSize];
}

@end
