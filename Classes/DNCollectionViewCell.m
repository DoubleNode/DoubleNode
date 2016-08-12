//
//  DNCollectionViewCell.m
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNCollectionViewCell.h"

@implementation DNCollectionViewCell

+ (NSString*)className
{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Workaround for resize nib problem with Xcode6/iOS8
    // re: http://stackoverflow.com/a/25768887
    self.contentView.frame = self.bounds;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

@end
