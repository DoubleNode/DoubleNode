//
//  DoubleNodeTestCase.m
//  DoubleNodeDemoTests
//
//  Created by Darren Ehlers on 10/30/13.
//  Copyright (c) 2013 DoubleNode. All rights reserved.
//

#import "DoubleNodeTestCase.h"

#import "CDTestDataModel.h"

@implementation DoubleNodeTestCase

- (void)setUp
{
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[CDTestDataModel dataModel] deletePersistentStore];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[CDTestDataModel dataModel] deletePersistentStore];

    [super tearDown];
}

#pragma mark - Helpers

- (CDOCompany*)insertFakeCompanyWithFiveEmployees
{
    CDOCompany* company = [CDOCompany foundryBuildWithContext:nil];
    return company;
}

- (CDOEmployee*)insertFakeEmployee
{
    CDOEmployee*    employee = [CDOEmployee foundryBuildWithContext:nil];
    return employee;
}

@end
