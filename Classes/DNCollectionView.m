//
//  DNCollectionView.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <CoreData/CoreData.h>

#import "DNCollectionView.h"

@interface DNCollectionView ()
{
    NSMutableArray*     objectChanges;
    NSMutableArray*     sectionChanges;
}

@end

@implementation DNCollectionView

- (void)beginUpdates
{
    objectChanges   = [NSMutableArray array];
    sectionChanges  = [NSMutableArray array];
}

- (void)endUpdates
{
    if ([sectionChanges count] > 0)
    {
        [self performBatchUpdates:^
         {
             for (NSDictionary*  change in sectionChanges)
             {
                 [change enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id obj, BOOL* stop)
                  {
                      NSFetchedResultsChangeType  type = [key unsignedIntegerValue];
                      switch (type)
                      {
                          case NSFetchedResultsChangeInsert:
                          {
                              [super insertSections:obj];
                              break;
                          }

                          case NSFetchedResultsChangeDelete:
                          {
                              [super deleteSections:obj];
                              break;
                          }

                          case NSFetchedResultsChangeUpdate:
                          {
                              [super reloadSections:obj];
                              break;
                          }

                          case NSFetchedResultsChangeMove:
                          {
                              [super moveSection:[obj[0] integerValue] toSection:[obj[1] integerValue]];
                              break;
                          }
                      }
                  }];
             }
         }
                       completion:nil];
    }

    // DME: Skip Object Changes when Section Changes are being done?????
    if ([objectChanges count] > 0 && [sectionChanges count] == 0)
    {
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || (self.window == nil))
        {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self reloadData];
        }
        else
        {
            [self performBatchUpdates:^
             {
                 for (NSDictionary* change in objectChanges)
                 {
                     [change enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id obj, BOOL* stop)
                      {
                          NSFetchedResultsChangeType  type = [key unsignedIntegerValue];
                          switch (type)
                          {
                              case NSFetchedResultsChangeInsert:
                              {
                                  [self insertItemsAtIndexPaths:obj];
                                  break;
                              }

                              case NSFetchedResultsChangeDelete:
                              {
                                  [self deleteItemsAtIndexPaths:obj];
                                  break;
                              }

                              case NSFetchedResultsChangeUpdate:
                              {
                                  [self reloadItemsAtIndexPaths:obj];
                                  break;
                              }

                              case NSFetchedResultsChangeMove:
                              {
                                  [self moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                  break;
                              }
                          }
                      }];
                 }
             }
                           completion:nil];
        }
    }
    
    [objectChanges removeAllObjects];
    [sectionChanges removeAllObjects];
}

- (void)insertSections:(NSIndexSet*)sections
{
    [sectionChanges addObject:@{ @(NSFetchedResultsChangeInsert): [sections copy] }];
}

- (void)deleteSections:(NSIndexSet*)sections
{
    [sectionChanges addObject:@{ @(NSFetchedResultsChangeDelete): [sections copy] }];
}

- (void)reloadSections:(NSIndexSet*)sections
{
    [sectionChanges addObject:@{ @(NSFetchedResultsChangeUpdate): [sections copy] }];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    [sectionChanges addObject:@{ @(NSFetchedResultsChangeMove): @[ @(section), @(newSection) ] }];
}

- (void)insertRowsAtIndexPaths:(NSArray*)indexPaths
{
    [objectChanges addObject:@{ @(NSFetchedResultsChangeInsert): [indexPaths copy] }];
}

- (void)deleteRowsAtIndexPaths:(NSArray*)indexPaths
{
    [objectChanges addObject:@{ @(NSFetchedResultsChangeDelete): [indexPaths copy] }];
}

- (void)reloadRowsAtIndexPaths:(NSArray*)indexPaths
{
    [objectChanges addObject:@{ @(NSFetchedResultsChangeUpdate): [indexPaths copy] }];
}

- (void)moveRowAtIndexPath:(NSIndexPath*)indexPath toIndexPath:(NSIndexPath*)newIndexPath
{
    [objectChanges addObject:@{ @(NSFetchedResultsChangeMove): @[ [indexPath copy], [newIndexPath copy] ] }];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    __block BOOL    shouldReload = NO;

    for (NSDictionary* change in objectChanges)
    {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, NSArray* obj, BOOL* stop)
         {
             NSFetchedResultsChangeType  type = [key unsignedIntegerValue];

             [obj enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL* stop)
              {
                  switch (type)
                  {
                      case NSFetchedResultsChangeInsert:
                      {
                          if ([self numberOfItemsInSection:obj.section] == 0)
                          {
                              shouldReload = YES;
                              *stop = YES;
                          }
                          break;
                      }

                      case NSFetchedResultsChangeDelete:
                      {
                          if ([self numberOfItemsInSection:obj.section] == 1)
                          {
                              shouldReload = YES;
                              *stop = YES;
                          }
                          break;
                      }

                      case NSFetchedResultsChangeUpdate:
                      case NSFetchedResultsChangeMove:
                      {
                          break;
                      }
                  }
              }];

             if (shouldReload)
             {
                 *stop = YES;
             }
         }];
    }

    return shouldReload;
}

@end
