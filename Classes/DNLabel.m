//
//  DNLabel.m
//  Pods
//
//  Created by Darren Ehlers on 11/8/13.
//
//

#import "DNLabel.h"

@implementation DNLabel

- (void) drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = { rect.origin.x + self.horizontalPadding, rect.origin.y + self.verticalPadding, rect.size.width - self.horizontalPadding * 2, rect.size.height - self.verticalPadding * 2};

    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
