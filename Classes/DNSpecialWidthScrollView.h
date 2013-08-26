//
//  DNSpecialWidthScrollView.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/29/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNSpecialWidthScrollView : UIScrollView

@property (nonatomic, assign) UIEdgeInsets responseInsets;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end
