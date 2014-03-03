//
//  DNLabel.h
//  Pods
//
//  Created by Darren Ehlers on 11/8/13.
//
//

#import <UIKit/UIKit.h>

#import "TTTAttributedLabel.h"

typedef enum
{
    DNLabelVerticalAlignmentCenter  = TTTAttributedLabelVerticalAlignmentCenter,
    DNLabelVerticalAlignmentTop     = TTTAttributedLabelVerticalAlignmentTop,
    DNLabelVerticalAlignmentBottom  = TTTAttributedLabelVerticalAlignmentBottom,
}
DNLabelVerticalAlignment;

@interface DNLabel : TTTAttributedLabel

@property (nonatomic, assign) float verticalPadding;
@property (nonatomic, assign) float horizontalPadding;

@end
