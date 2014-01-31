//
//  DNModelWatchObjects.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNModelWatch.h"

@class DNModelWatchObjects;

typedef void(^DNModelWatchObjectsWillChangeHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects);
typedef void(^DNModelWatchObjectsDidChangeHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects);

typedef void(^DNModelWatchObjectsDidChangeSectionInsertHandlerBlock)(DNModelWatchObjects* watch, id <NSFetchedResultsSectionInfo> section, NSUInteger sectionIndex);
typedef void(^DNModelWatchObjectsDidChangeSectionDeleteHandlerBlock)(DNModelWatchObjects* watch, id <NSFetchedResultsSectionInfo> section, NSUInteger sectionIndex);

typedef void(^DNModelWatchObjectsDidChangeObjectInsertHandlerBlock)(DNModelWatchObjects* watch, id object, NSIndexPath* indexPath, NSIndexPath* newIndexPath);
typedef void(^DNModelWatchObjectsDidChangeObjectDeleteHandlerBlock)(DNModelWatchObjects* watch, id object, NSIndexPath* indexPath, NSIndexPath* newIndexPath);
typedef void(^DNModelWatchObjectsDidChangeObjectUpdateHandlerBlock)(DNModelWatchObjects* watch, id object, NSIndexPath* indexPath, NSIndexPath* newIndexPath);
typedef void(^DNModelWatchObjectsDidChangeObjectMoveHandlerBlock)(DNModelWatchObjects* watch, id object, NSIndexPath* indexPath, NSIndexPath* newIndexPath);

@interface DNModelWatchObjects : DNModelWatch

@property (strong, nonatomic) DNModelWatchObjectsWillChangeHandlerBlock     willChangeHandler;
@property (strong, nonatomic) DNModelWatchObjectsDidChangeHandlerBlock      didChangeHandler;

@property (strong, nonatomic) DNModelWatchObjectsDidChangeSectionInsertHandlerBlock     didChangeSectionInsertHandler;
@property (strong, nonatomic) DNModelWatchObjectsDidChangeSectionDeleteHandlerBlock     didChangeSectionDeleteHandler;

@property (strong, nonatomic) DNModelWatchObjectsDidChangeObjectInsertHandlerBlock      didChangeObjectInsertHandler;
@property (strong, nonatomic) DNModelWatchObjectsDidChangeObjectDeleteHandlerBlock      didChangeObjectDeleteHandler;
@property (strong, nonatomic) DNModelWatchObjectsDidChangeObjectUpdateHandlerBlock      didChangeObjectUpdateHandler;
@property (strong, nonatomic) DNModelWatchObjectsDidChangeObjectMoveHandlerBlock        didChangeObjectMoveHandler;

- (id)initWithModel:(DNModel*)model;
- (id)initWithModel:(DNModel*)model willChange:(DNModelWatchObjectsWillChangeHandlerBlock)willChangeHandler didChange:(DNModelWatchObjectsDidChangeHandlerBlock)didChangeHandler;

- (NSArray*)objects;

@end
