//
//  DNCollectionView.h
//  Pods
//
//  Created by Darren Ehlers on 11/8/13.
//
//

#import <UIKit/UIKit.h>

@interface DNCollectionView : UICollectionView

- (void)beginUpdates;   // allow multiple insert/delete of rows and sections to be animated simultaneously. Nestable
- (void)endUpdates;     // only call insert/delete/reload calls or change the editing state inside an update block.  otherwise things like row count, etc. may be invalid.

- (void)insertSections:(NSIndexSet*)sections;
- (void)deleteSections:(NSIndexSet*)sections;
- (void)reloadSections:(NSIndexSet*)sections;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)insertRowsAtIndexPaths:(NSArray*)indexPaths;
- (void)deleteRowsAtIndexPaths:(NSArray*)indexPaths;
- (void)reloadRowsAtIndexPaths:(NSArray*)indexPaths;
- (void)moveRowAtIndexPath:(NSIndexPath*)indexPath toIndexPath:(NSIndexPath*)newIndexPath;

@end
