//
//  DNEventInterceptWindow.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 11/1/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNEventInterceptWindow.h"

@implementation DNEventInterceptWindow

- (void)sendEvent:(UIEvent *)event
{
    if ([_eventInterceptDelegate interceptEvent:event] == NO)
    {
        [super sendEvent:event];
    }
}

@end
