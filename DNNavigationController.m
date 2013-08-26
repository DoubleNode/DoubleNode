//
//  DNNavigationController.m
//  MZ Proto
//
//  Created by Darren Ehlers on 5/6/13.
//  Copyright (c) 2013 DoubleNode.com. All rights reserved.
//

#import "DNNavigationController.h"

@interface DNNavigationController ()

@end

@implementation DNNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.delegate   = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if (self.completionBlock)
    {
        self.completionBlock();
        self.completionBlock = nil;
    }
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                completion:(dispatch_block_t)completionBlock
{
    self.completionBlock    = completionBlock;
    
    [self pushViewController:viewController animated:animated];
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated
                                    completion:(dispatch_block_t)completionBlock
{
    self.completionBlock    = completionBlock;
    
    return [self popViewControllerAnimated:animated];
}

@end
