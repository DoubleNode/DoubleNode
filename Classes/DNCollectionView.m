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

//#define D2LogMarker ;
#define D2LogMarker NSLog

@interface DNCollectionView ()
{
    NSMutableArray* insertBlocks;
    NSMutableArray* deleteBlocks;
    NSMutableArray* reloadBlocks;
    NSMutableArray* moveBlocks;
    
    BOOL            shouldReloadCollectionView;
    NSInteger       sectionCount;
    NSMutableArray* objectCounts;
}

@end

@implementation DNCollectionView

- (void)beginUpdates
{
    //DOLog(LL_Debug, LD_General, @"[%@] beginUpdates - 1", self.name);
    if (insertBlocks)
    {
        DOLog(LL_Debug, LD_General, @"[%@] beginUpdates - 1a *** REENTERED insertBlocks ***", self.name);
    }
    insertBlocks                = [NSMutableArray array];

    if (deleteBlocks)
    {
        DOLog(LL_Debug, LD_General, @"[%@] beginUpdates - 1a *** REENTERED deleteBlocks ***", self.name);
    }
    deleteBlocks                = [NSMutableArray array];

    if (reloadBlocks)
    {
        DOLog(LL_Debug, LD_General, @"[%@] beginUpdates - 1a *** REENTERED reloadBlocks ***", self.name);
    }
    reloadBlocks                = [NSMutableArray array];

    if (moveBlocks)
    {
        DOLog(LL_Debug, LD_General, @"[%@] beginUpdates - 1a *** REENTERED moveBlocks ***", self.name);
    }
    moveBlocks                = [NSMutableArray array];

    shouldReloadCollectionView  = NO;
    
    objectCounts    = [NSMutableArray array];
    sectionCount    = [self numberOfSections];
    DOLog(LL_Debug, LD_General, @"[%@] beginUpdates - 2 sectionCount=%d", self.name, sectionCount);
    for (int section = 0; section < sectionCount; section++)
    {
        [objectCounts addObject:@([self numberOfItemsInSection:section])];
        //DOLog(LL_Debug, LD_General, @"[%@] beginUpdates - 3 [section:%d] objectCount=%@", self.name, section, objectCounts[section]);
    }
}

- (void)endUpdates
{
    //DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 1", self.name);
    if (self.isPaused || (self.window == nil) || shouldReloadCollectionView)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 1a", self.name);
        [self reloadData];
        
        //DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 1b", self.name);
        insertBlocks    = nil;
        deleteBlocks    = nil;
        reloadBlocks    = nil;
        moveBlocks      = nil;
        //DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 1c", self.name);
        return;
    }
    
    @try
    {
        //DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 2", self.name);
        //DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 2a sectionCount=%d", self.name, [self numberOfSections]);
        for (int section = 0; section < sectionCount; section++)
        {
            //DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 2b [section:%d] objectCount=%@", self.name, section, @([self numberOfItemsInSection:section]));
        }

        //DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 2c", self.name);
        [self performBatchUpdates:
         ^()
         {
             __block NSUInteger insertCount = 0;
             
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 3a", self.name);
             [insertBlocks enumerateObjectsUsingBlock:
              ^(void(^block)(void), NSUInteger idx, BOOL* stop)
              {
                  insertCount++;
                  block();
              }];
             
             __block NSUInteger deleteCount = 0;
             
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 3b", self.name);
             [deleteBlocks enumerateObjectsUsingBlock:
              ^(void(^block)(void), NSUInteger idx, BOOL* stop)
              {
                  deleteCount++;
                  block();
              }];
             
             __block NSUInteger reloadCount = 0;
             
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 3c", self.name);
             [reloadBlocks enumerateObjectsUsingBlock:
              ^(void(^block)(void), NSUInteger idx, BOOL* stop)
              {
                  reloadCount++;
                  block();
              }];
             
             __block NSUInteger moveCount = 0;
             
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 3d", self.name);
             [moveBlocks enumerateObjectsUsingBlock:
              ^(void(^block)(void), NSUInteger idx, BOOL* stop)
              {
                  moveCount++;
                  block();
              }];
             
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 4 (insertCount=%d)", self.name, insertCount);
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 4 (deleteCount=%d)", self.name, deleteCount);
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 4 (reloadCount=%d)", self.name, reloadCount);
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 4 (moveCount=%d)", self.name, moveCount);
         }
                       completion:
         ^(BOOL finished)
         {
             DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 5", self.name);
         }];

        insertBlocks    = nil;
        deleteBlocks    = nil;
        reloadBlocks    = nil;
        moveBlocks      = nil;
        DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 6", self.name);
    }
    @catch (NSException* exception)
    {
        DOLog(LL_Debug, LD_General, @"[%@] endUpdates - 7", self.name);

        DLog(LL_Error, LD_General, @"[%@] exception=%@", self.name, exception);
        insertBlocks    = nil;
        deleteBlocks    = nil;
        reloadBlocks    = nil;
        moveBlocks      = nil;

        if (self.recovery)
        {
            [self.recovery collectionView:self fatalErrorRecovery:exception];
        }
        
        // DME-DEBUG
        //[self reloadData];
        //[self reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionCount)]];
        //[self reloadItemsAtIndexPaths:[self indexPathsForVisibleItems]];
        //[self.collectionViewLayout invalidateLayout];
    }
}

- (void)insertSections:(NSIndexSet*)sections
{
    //DOLog(LL_Debug, LD_General, @"[%@] insertSections [%d]", self.name, [sections firstIndex]);
    [insertBlocks addObject:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"[%@] insertSections:block [%d]", self.name, [sections firstIndex]);
         [super insertSections:sections];
     }];
}

- (void)deleteSections:(NSIndexSet*)sections
{
    //DOLog(LL_Debug, LD_General, @"[%@] deleteSections [%d]", self.name, [sections firstIndex]);
    [deleteBlocks addObject:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"[%@] deleteSections:block [%d]", self.name, [sections firstIndex]);
         [super deleteSections:sections];
     }];
}

- (void)reloadSections:(NSIndexSet*)sections
{
    //DOLog(LL_Debug, LD_General, @"[%@] reloadSections [%d]", self.name, [sections firstIndex]);
    [reloadBlocks addObject:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"[%@] reloadSections:block [%d]", self.name, [sections firstIndex]);
         [super reloadSections:sections];
     }];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    //DOLog(LL_Debug, LD_General, @"[%@] moveSection [%d]-[%d]", self.name, section, newSection);
    [moveBlocks addObject:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"[%@] moveSection:block [%d]-[%d]", self.name, section, newSection);
         [super moveSection:section toSection:newSection];
     }];
}

- (void)insertRowsAtIndexPaths:(NSArray*)indexPaths
{
    if (sectionCount == 0)
    {
        shouldReloadCollectionView = YES;
        return;
    }

    //NSIndexPath*    indexPath = [indexPaths firstObject];
    //if ([objectCounts[indexPath.section] intValue] == 0)
    //{
    //    shouldReloadCollectionView = YES;
    //    return;
    //}

    NSArray*    indexPathsArray = [NSArray arrayWithArray:indexPaths];
    
    __block DNCollectionView*   bSelf   = self;
    
    //DOLog(LL_Debug, LD_General, @"[%@] insertRowsAtIndexPaths (%d)[%d:%d]", self.name, [indexPathsArray count], ((NSIndexPath*)indexPathsArray[0]).section, ((NSIndexPath*)indexPathsArray[0]).row);
    [insertBlocks addObject:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"[%@] insertRowsAtIndexPaths:block (%d)[%d:%d]", self.name, [indexPathsArray count], ((NSIndexPath*)indexPathsArray[0]).section, ((NSIndexPath*)indexPathsArray[0]).row);
         if ([indexPathsArray count] > 1)
         {
             DOLog(LL_Debug, LD_General, @"count error");
         }
         [bSelf insertItemsAtIndexPaths:indexPathsArray];
     }];
}

- (void)deleteRowsAtIndexPaths:(NSArray*)indexPaths
{
    NSIndexPath*    indexPath = [indexPaths firstObject];
    if ([objectCounts[indexPath.section] intValue] == 1)
    {
        shouldReloadCollectionView = YES;
        return;
    }
    
    NSArray*    indexPathsArray = [NSArray arrayWithArray:indexPaths];
    
    __block DNCollectionView*   bSelf   = self;
    
    //DOLog(LL_Debug, LD_General, @"[%@] deleteRowsAtIndexPaths (%d)[%d:%d]", self.name, [indexPathsArray count], ((NSIndexPath*)indexPathsArray[0]).section, ((NSIndexPath*)indexPathsArray[0]).row);
    [deleteBlocks addObject:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"[%@] deleteRowsAtIndexPaths:block (%d)[%d:%d]", self.name, [indexPathsArray count], ((NSIndexPath*)indexPathsArray[0]).section, ((NSIndexPath*)indexPathsArray[0]).row);
         [bSelf deleteItemsAtIndexPaths:indexPathsArray];
     }];
}

- (void)reloadRowsAtIndexPaths:(NSArray*)indexPaths
{
    NSArray*    indexPathsArray = [NSArray arrayWithArray:indexPaths];
    
    __block DNCollectionView*   bSelf   = self;
    
    //DOLog(LL_Debug, LD_General, @"[%@] reloadRowsAtIndexPaths (%d)[%d:%d]", self.name, [indexPathsArray count], ((NSIndexPath*)indexPathsArray[0]).section, ((NSIndexPath*)indexPathsArray[0]).row);
    [reloadBlocks addObject:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"[%@] reloadRowsAtIndexPaths:block (%d)[%d:%d]", self.name, [indexPathsArray count], ((NSIndexPath*)indexPathsArray[0]).section, ((NSIndexPath*)indexPathsArray[0]).row);
         [bSelf reloadItemsAtIndexPaths:indexPathsArray];
     }];
}

- (void)moveRowAtIndexPath:(NSIndexPath*)indexPath toIndexPath:(NSIndexPath*)newIndexPath
{
    __block DNCollectionView*   bSelf   = self;
    
    //DOLog(LL_Debug, LD_General, @"[%@] moveRowAtIndexPath [%d:%d]-[%d:%d]", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
    [moveBlocks addObject:
     ^()
     {
         //DOLog(LL_Debug, LD_General, @"[%@] moveRowAtIndexPath:block [%d:%d]-[%d:%d]", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
         [bSelf moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
     }];
}

@end
