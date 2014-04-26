//
//  DNLabel.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNLabel.h"

#import "DNUtilities.h"

@implementation DNLabel

- (void) drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = UIEdgeInsetsMake(self.verticalPadding, self.horizontalPadding, self.verticalPadding, self.horizontalPadding);
    DLog(LL_Debug, LD_Theming, @"insets=(%.2f, %.2f, %.2f, %.2f)", insets.top, insets.left, insets.bottom, insets.right);

    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


- (void)setText:(id)text
{
    if (!text)
    {
        self.attributedText = nil;
        return;
    }

    NSDictionary*   attributes  = nil;
    if (self.attributedText && ([self.attributedText length] > 0))
    {
        attributes = [self.attributedText attributesAtIndex:0 effectiveRange:NULL];
    }

    self.attributedText  = [[NSAttributedString alloc] initWithString:text
                                                           attributes:attributes];
}

@end
