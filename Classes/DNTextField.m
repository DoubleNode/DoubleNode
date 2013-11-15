//
//  DNTextField.m
//  Pods
//
//  Created by Darren Ehlers on 11/8/13.
//
//

#import "DNTextField.h"

@implementation DNTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + self.horizontalPadding, bounds.origin.y + self.verticalPadding, bounds.size.width - self.horizontalPadding * 2, bounds.size.height - self.verticalPadding * 2);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

@end
