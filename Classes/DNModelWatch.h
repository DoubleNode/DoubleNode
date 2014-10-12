//
//  DNModelWatch.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DNUtilities.h"

@class DNModel;

@interface DNModelWatch : NSObject

@property (strong, nonatomic) NSString* name;

@property (nonatomic, assign, getter=isPaused) BOOL paused;

- (id)initWithModel:(DNModel*)model;

- (void)startWatch;
- (BOOL)checkWatch;
- (void)cancelWatch;
- (void)refreshWatch;

- (void)pauseWatch;
- (void)resumeWatch;

- (void)executeWillChangeHandler:(NSDictionary*)context;
- (void)executeDidChangeHandler:(NSDictionary*)context;

- (void)executeDidChangeSectionInsertHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context;
- (void)executeDidChangeSectionDeleteHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context;

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context;
- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context;
- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context;
- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath*)newIndexPath
                                  context:(NSDictionary*)context;

- (BOOL)executeShouldChangeObjectUpdateHandler:(id)object
                                   atIndexPath:(NSIndexPath*)indexPath
                                  newIndexPath:(NSIndexPath*)newIndexPath
                                       context:(NSDictionary*)context;

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext* context))block;
- (void)performBlock:(void (^)(NSManagedObjectContext* context))block;

- (void)performWithContext:(NSManagedObjectContext*)context
              blockAndWait:(void (^)(NSManagedObjectContext* context))block;
- (void)performWithContext:(NSManagedObjectContext*)context
                     block:(void (^)(NSManagedObjectContext* context))block;

@end
