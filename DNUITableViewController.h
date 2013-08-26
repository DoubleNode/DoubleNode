//
//  DNUITableViewController.h
//  MZ Proto
//
//  Created by Darren Ehlers on 8/11/13.
//  Copyright (c) 2013 DoubleNode.com. All rights reserved.
//

#import <SensibleTableView/SensibleTableView.h>

#import "DNUIViewController.h"

@interface DNUITableViewController : SCTableViewController

- (BOOL)isSubViewVisible;
- (void)subViewWillAppear:(BOOL)animated;
- (void)subViewDidAppear:(BOOL)animated;
- (void)subViewWillDisappear:(BOOL)animated;
- (void)subViewDidDisappear:(BOOL)animated;

- (UIImage*)imageOfView;

@end
