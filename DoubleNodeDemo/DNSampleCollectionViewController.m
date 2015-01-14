//
//  DNSampleCollectionViewController.m
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/14/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "DNSampleCollectionViewController.h"

#import "DNDataModel.h"
#import "DNUtilities.h"
#import "DNModelWatchFetchedObjects.h"

#import "CDCompanyModel.h"

#import "CDOCompany.h"

#import "DNSampleCollectionViewCell.h"

@interface DNSampleCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    DNModelWatchFetchedObjects* companyWatch;
    
    CDCompanyModel* companyModel;
}

@end

@implementation DNSampleCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.collectionView.name    = NSStringFromClass([self.collectionView class]);
    
    [DNUtilities registerCellNib:[DNSampleCollectionViewCell className] withCollectionView:self.collectionView];
    
    companyModel    = [CDCompanyModel model];
    
    [[CDCompanyModel dataModel] createContextForCurrentThreadPerformBlockAndWait:
     ^BOOL(NSManagedObjectContext* context)
     {
         for (int j = 0; j < 100; j++)
         {
             [CDOCompany foundryBuildWithContext:context];
         }
         
         return YES;
     }];
    
    [self createCompanyWatch];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [companyWatch resumeWatch];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [companyWatch pauseWatch];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Company Watch

- (void)createCompanyWatch
{
    if (companyWatch)
    {
        [companyWatch cancelWatch];
        companyWatch    = nil;
    }
    
    companyWatch    = [companyModel watchAllWithCollectionView:self.collectionView offset:0 count:0];
    
    companyWatch.cellForItemAtIndexPathHandler = ^UICollectionViewCell*(DNModelWatchObjects* watch, UICollectionView* collectionView, NSIndexPath* indexPath)
    {
        DNSampleCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DNSampleCollectionViewCell className] forIndexPath:indexPath];
        
        cell.backgroundColor    = [UIColor whiteColor];
        cell.nameLabel.text     = [NSString stringWithFormat:@"indexPath = %ld/%ld", (long)indexPath.section, (long)indexPath.row];
        
        return cell;
    };
    
    companyWatch.didChangeHandler = ^(DNModelWatchObjects* watch, NSArray* objects, NSDictionary* context)
    {
        NSLog(@"companyWatch.didChangeHandler");
    };
    
    [companyWatch startWatch];
    [companyWatch pauseWatch];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 20;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return (CGSize){ 320, 50 };
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    DNSampleCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DNSampleCollectionViewCell className] forIndexPath:indexPath];
    NSAssert(cell, @"cell dequeue failed!");
    
    cell.backgroundColor    = [UIColor whiteColor];
    cell.nameLabel.text     = [NSString stringWithFormat:@"indexPath = %ld/%ld", (long)indexPath.section, (long)indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView*)collectionView
didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
}

@end
