//
//  DNEventInterceptWindow.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 11/1/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DNEventInterceptWindowDelegate

- (BOOL)interceptEvent:(UIEvent *)event; // return YES if event handled

@end

@interface DNEventInterceptWindow : UIWindow

@property (nonatomic, assign)   id<DNEventInterceptWindowDelegate>  eventInterceptDelegate;

@end
