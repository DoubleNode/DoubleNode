//
//  NSManagedObjectContext+description.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "NSManagedObjectContext+description.h"

@implementation NSManagedObjectContext (description)

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%@>", NSStringFromClass([self class]), [self.userInfo objectForKey:@"mocName"]];
}

@end
