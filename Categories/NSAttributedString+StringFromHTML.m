//
//  NSAttributedString+StringFromHTML.m
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

#import "NSAttributedString+StringFromHTML.h"

#import "ColorUtils.h"

@implementation NSAttributedString (StringFromHTML)

/// As we can't use the attributed string attributes params, so generate CSS from it

+ (NSString*)_cssStringFromAttributedStringAttributes:(NSDictionary*)dictionary
{
    NSMutableString*    cssString = [NSMutableString stringWithString:@"<style> p {"];

    if ([dictionary objectForKey:NSForegroundColorAttributeName])
    {
        UIColor*    color   = dictionary[NSForegroundColorAttributeName];
        [cssString appendFormat:@"color: %@;", [color stringValue]];
    }

    if ([dictionary objectForKey:NSFontAttributeName])
    {
        UIFont* font = dictionary[NSFontAttributeName];
        [cssString appendFormat:@"font-family:'%@'; font-size: %0.1fpx;", font.fontName, roundf(font.pointSize)];
    }

    if (dictionary[NSParagraphStyleAttributeName])
    {
        NSParagraphStyle*   style = dictionary[NSParagraphStyleAttributeName];
        [cssString appendFormat:@"line-height:%f em;", style.lineHeightMultiple];
    }

    [cssString appendString:@"}"];
    [cssString appendString:@"</style><body>"];

    return cssString;
}

+ (NSAttributedString*)attributedStringWithTextParams:(NSDictionary*)textParams
                                              andHTML:(NSString *)HTML
{
    NSDictionary*   importParams = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType };

    NSError*    error           = nil;
    NSString*   formatString    = [[self _cssStringFromAttributedStringAttributes:textParams] stringByAppendingFormat:@"%@</body>", HTML];
    NSData*     stringData      = [formatString dataUsingEncoding:NSUnicodeStringEncoding] ;

    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithData:stringData options:importParams documentAttributes:NULL error:&error];
    if (error)
    {
        return nil;
    }

    return attributedString;
}

@end
