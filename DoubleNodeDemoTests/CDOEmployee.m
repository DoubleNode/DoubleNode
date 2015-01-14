//
//  Employee.m
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "CDOEmployee.h"

#import "CDEmployeeModel.h"

@implementation CDOEmployee
CDO_DEFAULT_METHOD_INSTANCES(employee, Employee)

@dynamic birthdate;
@dynamic firstName;
@dynamic lastName;
@dynamic company;

+ (instancetype)foundryBuildWithContext:(NSManagedObjectContext*)context
{
    CDOEmployee*    employee = [super foundryBuildWithContext:context];
    
    return employee;
}

+ (NSDictionary*)foundryBuildSpecs
{
    NSMutableDictionary*    specs   = [[super foundryBuildSpecs] mutableCopy];
    
    [specs addEntriesFromDictionary:@{
                                      @"birthdate"      : [NSNumber numberWithInteger:FoundryPropertyTypeCustom],
                                      @"firstName"      : [NSNumber numberWithInteger:FoundryPropertyTypeFirstName],
                                      @"lastName"       : [NSNumber numberWithInteger:FoundryPropertyTypeLastName],
                                      }];
    
    return specs;
}

+ (id)foundryAttributeForProperty:(NSString*)property
{
    if ([property isEqualToString:@"birthdate"])
    {
        NSUInteger  day     = arc4random_uniform(86400 * 365 * 30);
        
        return [NSDate dateWithTimeIntervalSince1970:day];
    }
    
    return [super foundryAttributeForProperty:property];
}

@end
