//
//  CDOCompany.m
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "CDOCompany.h"
#import "CDOEmployee.h"

#import "CDCompanyModel.h"

@implementation CDOCompany
CDO_DEFAULT_METHOD_INSTANCES(company, Company)

CDO_TOMANY_ACCESSORS_INSTANCES(Employees, Employee)

@dynamic name;
@dynamic employees;

+ (instancetype)foundryBuildWithContext:(NSManagedObjectContext*)context
{
    CDOCompany* company = [super foundryBuildWithContext:context];
    
    [company addEmployeesObject:[CDOEmployee foundryCreateWithContext:context]];
    [company addEmployeesObject:[CDOEmployee foundryCreateWithContext:context]];
    [company addEmployeesObject:[CDOEmployee foundryCreateWithContext:context]];
    [company addEmployeesObject:[CDOEmployee foundryCreateWithContext:context]];
    [company addEmployeesObject:[CDOEmployee foundryCreateWithContext:context]];
    
    return company;
}

+ (NSDictionary*)foundryBuildSpecs
{
    NSMutableDictionary*    specs   = [[super foundryBuildSpecs] mutableCopy];
    
    [specs addEntriesFromDictionary:@{
                                      @"name"   : [NSNumber numberWithInteger:FoundryPropertyTypeFullName],
                                      }];
    
    return specs;
}

+ (id)foundryAttributeForProperty:(NSString*)property
{
    return [super foundryAttributeForProperty:property];
}

@end
