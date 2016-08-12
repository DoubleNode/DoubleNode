//
//  DNCollectionView.h
//  DoubleNode.com
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DNCollectionViewRecoveryProtocol;

@interface DNCollectionView : UICollectionView

@property (weak, nonatomic) id<DNCollectionViewRecoveryProtocol>    recovery;

@property (nonatomic, assign, getter=isPaused) BOOL paused;

@property (strong, nonatomic) NSString* name;

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

@protocol DNCollectionViewRecoveryProtocol <NSObject>

@required
- (void)collectionView:(DNCollectionView*)collectionView fatalErrorRecovery:(NSException*)exception;

@end
