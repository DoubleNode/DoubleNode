//
//  DNViewContainer.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNViewContainer.h"

#import "DNUtilities.h"

@implementation DNViewContainer

- (DNViewContainer*)initWithNibName:(NSString*)nibNameOrNil
                             bundle:(NSBundle*)nibBundleOrNil
{
    nibNameOrNil    = [DNUtilities appendNibSuffix:nibNameOrNil];
    
    if (nibBundleOrNil == nil)
    {
        nibBundleOrNil = [NSBundle mainBundle];
    }
    [nibBundleOrNil loadNibNamed:nibNameOrNil owner:self options:nil];

    return self;
}

@end
