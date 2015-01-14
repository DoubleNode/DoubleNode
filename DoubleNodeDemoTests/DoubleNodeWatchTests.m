//
//  DoubleNodeWatchTests.m
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/14/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "DoubleNodeTestCase.h"

@interface DoubleNodeWatchTests : DoubleNodeTestCase

@end

@implementation DoubleNodeWatchTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateWatch
{
    
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
