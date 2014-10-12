//
//  DNModelWatchFetchedObjects.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNUtilities.h"

#import "DNModelWatchObjects.h"

#import "DNModel.h"

@class DNCollectionView, DNModelWatchFetchedObjects;

typedef NSInteger(^DNModelWatchFetchedObjectsNumberOfItemsInSectionHandlerBlock)(DNModelWatchFetchedObjects* watch, UICollectionView* collectionView, NSInteger section);
typedef UICollectionViewCell*(^DNModelWatchFetchedObjectsCellForItemAtIndexPathHandlerBlock)(DNModelWatchFetchedObjects* watch, UICollectionView* collectionView, NSIndexPath* indexPath);
typedef NSInteger(^DNModelWatchFetchedObjectsNumberOfSectionsInCollectionViewHandlerBlock)(DNModelWatchFetchedObjects* watch, UICollectionView* collectionView);
typedef UICollectionReusableView*(^DNModelWatchFetchedObjectsViewForSupplementaryElementOfKindHandlerBlock)(DNModelWatchFetchedObjects* watch, UICollectionView* collectionView, NSString* kind, NSIndexPath* indexPath);

@interface DNModelWatchFetchedObjects : DNModelWatchObjects <UICollectionViewDataSource>

@property (nonatomic, retain) DNCollectionView*     collectionView;

@property (strong, nonatomic) DNModelWatchFetchedObjectsNumberOfItemsInSectionHandlerBlock              numberOfItemsInSectionHandler;
@property (strong, nonatomic) DNModelWatchFetchedObjectsCellForItemAtIndexPathHandlerBlock              cellForItemAtIndexPathHandler;
@property (strong, nonatomic) DNModelWatchFetchedObjectsNumberOfSectionsInCollectionViewHandlerBlock    numberOfSectionsInCollectionViewHandler;
@property (strong, nonatomic) DNModelWatchFetchedObjectsViewForSupplementaryElementOfKindHandlerBlock   viewForSupplementaryElementOfKindHandler;

+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch;
+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch andCollectionView:(DNCollectionView*)collectionView;

+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch groupBy:(NSString*)sectionKeyPath;
+ (id)watchWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch groupBy:(NSString*)sectionKeyPath andCollectionView:(DNCollectionView*)collectionView;

- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch;
- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch andCollectionView:(DNCollectionView*)collectionView;

- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch groupBy:(NSString*)sectionKeyPath;
- (id)initWithModel:(DNModel*)model andFetch:(NSFetchRequest*)fetch groupBy:(NSString*)sectionKeyPath andCollectionView:(DNCollectionView*)collectionView;

@end
