//
//  DNCellButton.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNCellButton : UIButton

// NSIndexPath provides a convenient way to store an integer pair
// Note we are using cellIndex.section to store the column (or button #)
@property (strong, nonatomic) NSIndexPath *cellIndex;

@end

