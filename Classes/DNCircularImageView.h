//
//  DNCircularImageView.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "NZCircularImageView.h"

@interface DNCircularImageView : NZCircularImageView

@property (nonatomic) UIImage*  blankImage;

@property (nonatomic) NSString* firstName;
@property (nonatomic) NSString* lastName;

@property (nonatomic) UIColor*  initialsBackgroundColor;
@property (nonatomic) UIColor*  initialsTextColor;
@property (nonatomic) UIFont*   initialsFont;

- (BOOL)isShowingInitials;

@end
