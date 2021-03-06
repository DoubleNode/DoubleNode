//
//  DoubleNodeCompanyTests.m
//  DoubleNodeDemoTests
//
//  Created by Darren Ehlers on 1/13/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "DoubleNodeTestCase.h"

#import "DNDataModel.h"
#import "CDCompanyModel.h"

const NSUInteger    kTestCompanyIDLength        = 36;
NSString* const     kTestCompanyName            = @"Test Company";
const NSUInteger    kTestCompanyEmployeesCount  = 5;

@interface DoubleNodeCompanyTests : DoubleNodeTestCase

@end

@implementation DoubleNodeCompanyTests

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

- (void)testSimpleCreateCompany
{
    CDOCompany* company = [CDOCompany company];
    company.id          = [[NSUUID UUID] UUIDString];
    company.name        = kTestCompanyName;

    XCTAssertNotNil(company);
    XCTAssertEqual([company.id length], kTestCompanyIDLength);
    XCTAssertEqualObjects(company.name, kTestCompanyName);
}

- (void)testCreateCompany
{
    __block CDOCompany* company;
    
    [[CDCompanyModel dataModel] createContextForCurrentThreadPerformBlockAndWait:
     ^BOOL(NSManagedObjectContext* context)
     {
         company        = [CDOCompany company];
         company.id     = [[NSUUID UUID] UUIDString];
         company.name   = kTestCompanyName;
         XCTAssertNotNil(company);
         XCTAssertEqual([company.id length], kTestCompanyIDLength);
         XCTAssertEqualObjects(company.name, kTestCompanyName);
         
         return YES;
     }];
    
    XCTAssertNotNil(company);
    XCTAssertEqual([company.id length], kTestCompanyIDLength);
    XCTAssertEqualObjects(company.name, kTestCompanyName);
}

- (void)testCreateCompanyAndEmployees
{
    __block CDOCompany* company;
    
    [[CDCompanyModel dataModel] createContextForCurrentThreadPerformBlockAndWait:
     ^BOOL(NSManagedObjectContext* context)
     {
         company    = [CDOCompany foundryBuildWithContext:context];

         XCTAssertNotNil(company);
         XCTAssertEqual([company.id length], kTestCompanyIDLength);
         XCTAssertEqual([company.employees count], kTestCompanyEmployeesCount);
         
         return YES;
     }];
    
    XCTAssertNotNil(company);
    XCTAssertEqual([company.id length], kTestCompanyIDLength);
    XCTAssertEqual([company.employees count], kTestCompanyEmployeesCount);
}

- (void)testCreate100000CompaniesAndEmployees
{
    for (int i = 0; i < 100; i++)
    {
        DLog(LL_Debug, LD_General, @"Creating block #%d of 100...", i);
        
        [[CDCompanyModel dataModel] createContextForCurrentThreadPerformBlockAndWait:
         ^BOOL(NSManagedObjectContext* context)
         {
             for (int j = 0; j < 1000; j++)
             {
                 __block CDOCompany* company    = [CDOCompany foundryBuildWithContext:context];
                 
                 XCTAssertNotNil(company);
                 XCTAssertEqual([company.id length], kTestCompanyIDLength);
                 XCTAssertEqual([company.employees count], kTestCompanyEmployeesCount);
             }
             
             return YES;
         }];
    }

    NSArray*    companies   = [[CDCompanyModel model] getAll];

    XCTAssertNotNil(companies);
    XCTAssertEqual([companies count], 100000);
}

@end
