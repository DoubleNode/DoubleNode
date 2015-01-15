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

@interface DNSampleCollectionViewController () <UICollectionViewDelegate>
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
    
    self.collectionView.name    = NSStringFromClass([self class]);
    
    [DNUtilities registerCellNib:[DNSampleCollectionViewCell className] withCollectionView:self.collectionView];
    
    [[CDCompanyModel dataModel] deletePersistentStore];

    companyModel    = [CDCompanyModel model];
    
    [[CDCompanyModel dataModel] createContextForCurrentThreadPerformBlockAndWait:
     ^BOOL(NSManagedObjectContext* context)
     {
         for (int j = 0; j < 10000; j++)
         {
             CDOCompany*    company = [CDOCompany foundryBuildWithContext:context];
             
             company.name   = [NSString stringWithFormat:@"%@ (#%d)", company.name, j + 1];
         }
         
         return YES;
     }];
    
    [DNUtilities runRepeatedlyAfterDelay:3.0f
                                   block:
     ^(BOOL* stop)
     {
         for (int i = 0; i < 10; i++)
         {
             [DNUtilities runOnBackgroundThread:
              ^()
              {
                  [[CDCompanyModel dataModel] createContextForCurrentThreadPerformBlockAndWait:
                   ^BOOL(NSManagedObjectContext* context)
                   {
                       NSArray*   companies   = [companyModel getAll];
                       
                       for (int j = 0; j < 50; j++)
                       {
                           int    idx = arc4random_uniform([companies count]);
                           
                           CDOCompany*    company = companies[idx];
                           
                           company.added  = [NSDate date];
                       }
                       
                       return YES;
                   }];
              }];
         }
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
    
    __block DNSampleCollectionViewController*   bSelf   = self;
    
    companyWatch.cellForItemAtIndexPathHandler = ^UICollectionViewCell*(DNModelWatchObjects* watch, UICollectionView* collectionView, NSIndexPath* indexPath)
    {
        CDOCompany* company = [bSelf->companyWatch objectAtIndexPath:indexPath];
        
        DNSampleCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DNSampleCollectionViewCell className] forIndexPath:indexPath];
        
        cell.backgroundColor        = [UIColor whiteColor];
        cell.nameLabel.text         = company.name;
        cell.timestampLabel.text    = [NSString stringWithFormat:@"%@", company.added];
        
        return cell;
    };
    
    companyWatch.didChangeHandler = ^(DNModelWatchObjects* watch, NSArray* objects, NSDictionary* context)
    {
        //NSLog(@"companyWatch.didChangeHandler");
    };
    
    [companyWatch startWatch];
    [companyWatch pauseWatch];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return (CGSize){ 320, 50 };
}

- (void)collectionView:(UICollectionView*)collectionView
didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
}

@end
