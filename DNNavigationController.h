//
//  DNNavigationController.h
//  MZ Proto
//
//  Created by Darren Ehlers on 5/6/13.
//  Copyright (c) 2013 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNNavigationController : UINavigationController <UINavigationControllerDelegate>

@property (nonatomic,copy) dispatch_block_t completionBlock;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(dispatch_block_t)completionBlock;
- (UIViewController*)popViewControllerAnimated:(BOOL)animated completion:(dispatch_block_t)completionBlock;

@end
