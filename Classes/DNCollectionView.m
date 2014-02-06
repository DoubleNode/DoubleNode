//
//  DNCollectionView.m
//  Pods
//
//  Created by Darren Ehlers on 11/8/13.
//
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

- (id)init
{
	self = [super init];
	if (self)
    {
        objectChanges   = [NSMutableArray array];
        sectionChanges  = [NSMutableArray array];
	}

	return self;
}

- (void)beginUpdates
{
    [objectChanges removeAllObjects];
    [sectionChanges removeAllObjects];
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
                              [self insertSections:obj];
                              break;
                          }

                          case NSFetchedResultsChangeDelete:
                          {
                              [self deleteSections:obj];
                              break;
                          }

                          case NSFetchedResultsChangeUpdate:
                          {
                              [self reloadSections:obj];
                              break;
                          }

                          case NSFetchedResultsChangeMove:
                          {
                              [self moveSection:[obj[0] integerValue] toSection:[obj[1] integerValue]];
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
    [sectionChanges addObject:@{ @(NSFetchedResultsChangeInsert): sections }];
}

- (void)deleteSections:(NSIndexSet*)sections
{
    [sectionChanges addObject:@{ @(NSFetchedResultsChangeDelete): sections }];
}

- (void)reloadSections:(NSIndexSet*)sections
{
    [sectionChanges addObject:@{ @(NSFetchedResultsChangeUpdate): sections }];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    [sectionChanges addObject:@{ @(NSFetchedResultsChangeMove): @[ @(section), @(newSection) ] }];
}

- (void)insertRowsAtIndexPaths:(NSArray*)indexPaths
{
    [objectChanges addObject:@{ @(NSFetchedResultsChangeInsert): indexPaths }];
}

- (void)deleteRowsAtIndexPaths:(NSArray*)indexPaths
{
    [objectChanges addObject:@{ @(NSFetchedResultsChangeDelete): indexPaths }];
}

- (void)reloadRowsAtIndexPaths:(NSArray*)indexPaths
{
    [objectChanges addObject:@{ @(NSFetchedResultsChangeUpdate): indexPaths }];
}

- (void)moveRowAtIndexPath:(NSIndexPath*)indexPath toIndexPath:(NSIndexPath*)newIndexPath
{
    [objectChanges addObject:@{ @(NSFetchedResultsChangeMove): @[ indexPath, newIndexPath ] }];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    __block BOOL    shouldReload = NO;

    for (NSDictionary* change in objectChanges)
    {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop)
         {
             NSIndexPath*    indexPath = obj;

             NSFetchedResultsChangeType  type = [key unsignedIntegerValue];
             switch (type)
             {
                 case NSFetchedResultsChangeInsert:
                 {
                     shouldReload = ([self numberOfItemsInSection:indexPath.section] == 0);
                     break;
                 }

                 case NSFetchedResultsChangeDelete:
                 {
                     shouldReload = ([self numberOfItemsInSection:indexPath.section] == 1);
                     break;
                 }

                 case NSFetchedResultsChangeUpdate:
                 case NSFetchedResultsChangeMove:
                 {
                     shouldReload = NO;
                     break;
                 }
             }
         }];
    }
    
    return shouldReload;
}

@end
