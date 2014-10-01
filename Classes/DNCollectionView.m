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

#import "DNUtilities.h"

#define D2LogMarker nada
//#define D2LogMarker NSLog

void nada() {   }

@interface DNCollectionView ()
{
    NSMutableArray*         updateBlocks;
    UICollectionViewCell*   currentCell;
}

@end

@implementation DNCollectionView

- (void)beginUpdates
{
    D2LogMarker(@"beginUpdates");
    updateBlocks    = [NSMutableArray array];
    currentCell     = [self.visibleCells firstObject];
}

- (void)endUpdates
{
    D2LogMarker(@"endUpdates - 1");
    //if (self.window == nil)
    {
        NSUInteger  sectionCount = [self numberOfSections];
        if (sectionCount > 0)
        {
            [self numberOfItemsInSection:0];
        }
    }
    D2LogMarker(@"endUpdates - 2");
    [self performBatchUpdates:
     ^()
     {
         D2LogMarker(@"endUpdates - 3");
         [updateBlocks enumerateObjectsUsingBlock:
          ^(void(^updateBlock)(void), NSUInteger idx, BOOL* stop)
          {
              updateBlock();
          }];
         
         D2LogMarker(@"endUpdates - 4");
     }
                   completion:
     ^(BOOL finished)
     {
         D2LogMarker(@"endUpdates - 5");
         if (currentCell)
         {
             NSIndexPath*   currentCellIndex    = [self indexPathForCell:currentCell];
             if ([NSStringFromClass([currentCell class]) isEqualToString:@"DetailPeopleCell"])
             {
                 DLog(LL_Debug, LD_General, @"DetailPeopleCell.currentCellIndex=%@", currentCellIndex);
                 DLog(LL_Debug, LD_General, @"break");
             }

             /*
             [self scrollToItemAtIndexPath:currentCellIndex
                          atScrollPosition:UICollectionViewScrollPositionTop
                                  animated:YES];
             */
             currentCell    = nil;
         }
     }];
}

- (void)insertSections:(NSIndexSet*)sections
{
    D2LogMarker(@"insertSections [%d]", [sections firstIndex]);
    [updateBlocks addObject:
     ^()
     {
         D2LogMarker(@"insertSections:block [%d]", [sections firstIndex]);
         [super insertSections:sections];
     }];
}

- (void)deleteSections:(NSIndexSet*)sections
{
    D2LogMarker(@"deleteSections [%d]", [sections firstIndex]);
    [updateBlocks addObject:
     ^()
     {
         D2LogMarker(@"deleteSections:block [%d]", [sections firstIndex]);
         [super deleteSections:sections];
     }];
}

- (void)reloadSections:(NSIndexSet*)sections
{
    D2LogMarker(@"reloadSections [%d]", [sections firstIndex]);
    [updateBlocks addObject:
     ^()
     {
         D2LogMarker(@"reloadSections:block [%d]", [sections firstIndex]);
         [super reloadSections:sections];
     }];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    D2LogMarker(@"moveSection [%d]-[%d]", section, newSection);
    [updateBlocks addObject:
     ^()
     {
         D2LogMarker(@"moveSection:block [%d]-[%d]", section, newSection);
         [super moveSection:section toSection:newSection];
     }];
}

- (void)insertRowsAtIndexPaths:(NSArray*)indexPaths
{
    NSArray*    indexPathsArray = [NSArray arrayWithArray:indexPaths];
    
    D2LogMarker(@"insertRowsAtIndexPaths [%d:%d]", ((NSIndexPath*)indexPaths[0]).section, ((NSIndexPath*)indexPaths[0]).row);
    [updateBlocks addObject:
     ^()
     {
         D2LogMarker(@"insertRowsAtIndexPaths:block [%d:%d]", ((NSIndexPath*)indexPaths[0]).section, ((NSIndexPath*)indexPaths[0]).row);
         [self insertItemsAtIndexPaths:indexPathsArray];
     }];
}

- (void)deleteRowsAtIndexPaths:(NSArray*)indexPaths
{
    NSArray*    indexPathsArray = [NSArray arrayWithArray:indexPaths];
    
    D2LogMarker(@"deleteRowsAtIndexPaths [%d:%d]", ((NSIndexPath*)indexPaths[0]).section, ((NSIndexPath*)indexPaths[0]).row);
    [updateBlocks addObject:
     ^()
     {
         D2LogMarker(@"deleteRowsAtIndexPaths:block [%d:%d]", ((NSIndexPath*)indexPaths[0]).section, ((NSIndexPath*)indexPaths[0]).row);
         [self deleteItemsAtIndexPaths:indexPathsArray];
     }];
}

- (void)reloadRowsAtIndexPaths:(NSArray*)indexPaths
{
    NSArray*    indexPathsArray = [NSArray arrayWithArray:indexPaths];
    
    D2LogMarker(@"reloadRowsAtIndexPaths [%d:%d]", ((NSIndexPath*)indexPaths[0]).section, ((NSIndexPath*)indexPaths[0]).row);
    [updateBlocks addObject:
     ^()
     {
         D2LogMarker(@"reloadRowsAtIndexPaths:block [%d:%d]", ((NSIndexPath*)indexPaths[0]).section, ((NSIndexPath*)indexPaths[0]).row);
         [self reloadItemsAtIndexPaths:indexPathsArray];
     }];
}

- (void)moveRowAtIndexPath:(NSIndexPath*)indexPath toIndexPath:(NSIndexPath*)newIndexPath
{
    D2LogMarker(@"moveRowAtIndexPath [%d:%d]-[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
    [updateBlocks addObject:
     ^()
     {
         D2LogMarker(@"moveRowAtIndexPath:block [%d:%d]-[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
         [self moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
     }];
}

@end
