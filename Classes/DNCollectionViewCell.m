//
//  DNCollectionViewCell.m
//  Phoenix
//
//  Created by Darren Ehlers on 9/16/14.
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//

#import "DNCollectionViewCell.h"

@implementation DNCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Workaround for resize nib problem with Xcode6/iOS8
    // re: http://stackoverflow.com/a/25768887
    self.contentView.frame = self.bounds;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

@end
