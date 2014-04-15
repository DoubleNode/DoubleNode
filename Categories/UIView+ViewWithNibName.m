//
//  UIView+ViewWithNibName.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "UIView+ViewWithNibName.h"

@implementation UIView (ViewWithNibName)

+ (UIView*)viewWithNibName:(NSString*)nibName owner:(NSObject*)owner
{
    NSArray*        nibContents     = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:NULL];
    NSEnumerator*   nibEnumerator   = [nibContents objectEnumerator];

    id          customView  = nil;
    NSObject*   nibItem     = nil;

    while ((nibItem = [nibEnumerator nextObject]) != nil)
    {
        if ([nibItem isKindOfClass:[self class]])
        {
            customView = nibItem;
            break;
        }
    }
    
    return customView;
}

@end
