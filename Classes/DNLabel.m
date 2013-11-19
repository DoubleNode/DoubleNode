//
//  DNLabel.m
//  Pods
//
//  Created by Darren Ehlers on 11/8/13.
//
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

@end
