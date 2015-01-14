//
//  DoubleNodeTestCase.h
//  DoubleNodeDemoTests
//
//  Created by Darren Ehlers on 10/30/13.
//  Copyright (c) 2013 DoubleNode. All rights reserved.
//

@import XCTest;

// Test Model
#import "CDOEmployee.h"
#import "CDOCompany.h"

@interface DoubleNodeTestCase : XCTestCase

#pragma mark - Helpers

- (CDOCompany*)insertFakeCompanyWithFiveEmployees;
- (CDOEmployee*)insertFakeEmployee;

@end
