//
//  DNTextView.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JustType/JustType.h>

@interface DNTextView : JTTextView

/**
 * The placeholder text if no text has been entered yet.
 */
@property (strong, nonatomic) NSString* placeholder;

@property (strong, nonatomic) UIColor*  placeholderColor;

- (void)shake;

/**
 Height of content given current width
 */
- (CGFloat)contentHeight;

@end
