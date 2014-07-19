//
//  DNCircularImageView.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNUtilities.h"
#import "DNCircularImageView.h"

@implementation DNCircularImageView

- (BOOL)isShowingInitials
{
    return ((self.image == nil) || (self.image == self.blankImage));
}

- (void)setFirstName:(NSString*)firstName
{
    _firstName                  = firstName;
    _initialsBackgroundColor    = nil;
    self.image                  = nil;

    [self setNeedsLayout];
}

- (void)setLastName:(NSString*)lastName
{
    _lastName                   = lastName;
    _initialsBackgroundColor    = nil;
    self.image                  = nil;

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (self.isShowingInitials)
    {
        if (([_firstName length] > 0) && ([_lastName length] > 0))
        {
            if (!_initialsFont)
            {
                _initialsFont               = [UIFont systemFontOfSize:18.0f];
            }
            if (!_initialsTextColor)
            {
                _initialsTextColor          = [UIColor whiteColor];
            }
            if (!_initialsBackgroundColor)
            {
                _initialsBackgroundColor    = [self randomColor];
            }

            if (self.image == nil)
            {
                [self drawCircle];
            }
            
            [self addText];
        }
    }

    [super layoutSubviews];
}

- (UIColor*)randomColor
{
    CGFloat hue         = (arc4random() % 128 / 256.0) + 0.25;
    CGFloat saturation  = (arc4random() % 128 / 256.0) + 0.25;
    CGFloat brightness  = (arc4random() % 128 / 256.0) + 0.25;

    if (([_firstName length] > 0) && ([_lastName length] > 0))
    {
        hue             = ([_firstName hash] % 128 / 256.0) + 0.25;
        saturation      = ([_lastName hash]  % 128 / 256.0) + 0.25;
        brightness      = ([[NSString stringWithFormat:@"%@ %@", _firstName, _lastName] hash] % 128 / 256.0) + 0.25;
    }

    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)drawCircle
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0f);

    CGContextRef    context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _initialsBackgroundColor.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));

    self.blankImage = UIGraphicsGetImageFromCurrentImageContext();
    self.image      = self.blankImage;

    UIGraphicsEndImageContext();
}

- (void)addText
{
    NSString*   initials = [self createInitials];

    NSMutableParagraphStyle*    paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];

    NSAttributedString* initialsString = [[NSAttributedString alloc] initWithString:initials
                                                                         attributes:@{NSFontAttributeName:_initialsFont, NSForegroundColorAttributeName:_initialsTextColor, NSParagraphStyleAttributeName:paragraphStyle}];

    UIGraphicsBeginImageContextWithOptions(self.blankImage.size, NO, 0.0f);

    [self.image drawAtPoint:CGPointMake(0.0f, 0.0f)];

    CGFloat     fontHeight  = _initialsFont.lineHeight;
    CGFloat     yOffset     = (self.frame.size.height - fontHeight) / 2.0;
    [initialsString drawInRect:CGRectMake(0, yOffset, self.frame.size.width, self.frame.size.height)];

    self.blankImage = UIGraphicsGetImageFromCurrentImageContext();
    self.image      = self.blankImage;

    UIGraphicsEndImageContext();
}

- (NSString*)createInitials
{
    NSMutableString*    initials = [[NSMutableString alloc]initWithString:[_firstName substringToIndex:1]];
    [initials appendString:[_lastName substringToIndex:1]];

    return [initials uppercaseString];
}

@end
