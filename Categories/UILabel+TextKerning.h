//
//  UILabel+TextKerning.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (TextKerning)

/**
*  Set the label's text to the given string, using the given kerning value if able. (i.e., if running on iOS 6.0+).
*
*  @param text    The text string to set the label to display
*  @param kerning The number of points by which to adjust spacing between characters (positive values increase spacing, negative values decrease spacing, a value of 0 is default)
*/
- (void) setText:(NSString *)text withKerning:(CGFloat)kerning;

/**
 *  Set the label's text to the given string, using the given kerning value if able. (i.e., if running on iOS 6.0+).
 *
 *  @param attrText The text string to set the label to display
 *  @param kerning  The number of points by which to adjust spacing between characters (positive values increase spacing, negative values decrease spacing, a value of 0 is default)
 */
-(void) setAttributedText:(NSAttributedString *)attrText withKerning:(CGFloat)kerning;

/**
 *  Set the kerning value of the currently-set text.
 *
 *  @param kerning The number of points by which to adjust spacing between characters (positive values increase spacing, negative values decrease spacing, a value of 0 is default)
 */
- (void) setKerning:(CGFloat)kerning;

@end