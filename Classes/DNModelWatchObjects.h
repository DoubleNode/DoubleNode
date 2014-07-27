//
//  DNModelWatchObjects.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNModelWatch.h"

@class DNModelWatchObjects;

typedef void(^DNModelWatchObjectsWillChangeHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects, NSDictionary* context);
typedef void(^DNModelWatchObjectsDidChangeHandlerBlock)(DNModelWatchObjects* watch, NSArray* objects, NSDictionary* context);

typedef void(^DNModelWatchObjectsDidChangeSectionInsertHandlerBlock)(DNModelWatchObjects* watch, id <NSFetchedResultsSectionInfo> section, NSUInteger sectionIndex, NSDictionary* context);
typedef void(^DNModelWatchObjectsDidChangeSectionDeleteHandlerBlock)(DNModelWatchObjects* watch, id <NSFetchedResultsSectionInfo> section, NSUInteger sectionIndex, NSDictionary* context);

typedef void(^DNModelWatchObjectsDidChangeObjectInsertHandlerBlock)(DNModelWatchObjects* watch, id object, NSIndexPath* newIndexPath, NSDictionary* context);
typedef void(^DNModelWatchObjectsDidChangeObjectDeleteHandlerBlock)(DNModelWatchObjects* watch, id object, NSIndexPath* indexPath, NSDictionary* context);
typedef void(^DNModelWatchObjectsDidChangeObjectUpdateHandlerBlock)(DNModelWatchObjects* watch, id object, NSIndexPath* indexPath, NSDictionary* context);
typedef void(^DNModelWatchObjectsDidChangeObjectMoveHandlerBlock)(DNModelWatchObjects* watch, id object, NSIndexPath* indexPath, NSIndexPath* newIndexPath, NSDictionary* context);

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

- (NSArray*)objects;

@end
