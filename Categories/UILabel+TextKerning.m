//
//  UILabel+TextKerning.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "UILabel+TextKerning.h"

@implementation UILabel (TextKerning)

-(void) setText:(NSString *)text withKerning:(CGFloat)kerning
{
    if ([self respondsToSelector:@selector(setAttributedText:)])
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedString addAttribute:NSKernAttributeName
                                 value:[NSNumber numberWithFloat:kerning]
                                 range:NSMakeRange(0, [text length])];
        [self setAttributedText:attributedString];
    }
    else
        [self setText:text];
}

-(void) setAttributedText:(NSAttributedString *)attrText withKerning:(CGFloat)kerning
{
    NSMutableAttributedString*  attributedString = [attrText mutableCopy];

    [attributedString addAttribute:NSKernAttributeName
                             value:[NSNumber numberWithFloat:kerning]
                             range:NSMakeRange(0, [attrText length])];
    [self setAttributedText:attributedString];
}

-(void) setKerning:(CGFloat)kerning
{
    if ([self respondsToSelector:@selector(setAttributedText:)])
    {
        if (self.attributedText)
        {
            [self setAttributedText:self.attributedText withKerning:kerning];
            return;
        }
    }

    [self setText:self.text withKerning:kerning];
}

@end
