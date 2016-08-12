//
//  NSManagedObjectContext+description.m
//  DoubleNode.com
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
