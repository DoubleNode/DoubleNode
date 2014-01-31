//
//  DNModelWatch.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNUtilities.h"

@class DNModel;

@interface DNModelWatch : NSObject

- (id)initWithModel:(DNModel*)model;

- (void)startWatch;
- (BOOL)checkWatch;
- (void)cancelWatch;
- (void)refreshWatch;

- (void)executeWillChangeHandler;
- (void)executeDidChangeHandler;

- (void)executeDidChangeSectionInsertHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex;
- (void)executeDidChangeSectionDeleteHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex;

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath;
- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath;
- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath;
- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath *)newIndexPath;

@end
