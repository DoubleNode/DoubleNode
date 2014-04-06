//
//  NSManagedObjectContext+description.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "NSManagedObjectContext+description.h"

@implementation NSManagedObjectContext (description)

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%@>", NSStringFromClass([self class]), [self.userInfo objectForKey:@"mocName"]];
}

@end
