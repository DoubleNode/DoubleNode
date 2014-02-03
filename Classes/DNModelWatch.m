//
//  DNModelWatch.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNModelWatch.h"

#import "DNModel.h"

@interface DNModelWatch ()
{
    DNModel*    model;
}

@end

@implementation DNModelWatch

- (id)initWithModel:(DNModel*)myModel
{
    self = [super init];
    if (self)
    {
        model   = myModel;
        
        [model retainWatch:self];
    }
    
    return self;
}

- (void)startWatch
{
}

- (BOOL)checkWatch
{
    return [model checkWatch:self];
}

- (void)cancelWatch
{
    [model releaseWatch:self];
}

- (void)refreshWatch
{
}

- (void)executeWillChangeHandler
{
}

- (void)executeDidChangeHandler
{
}

- (void)executeDidChangeSectionInsertHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex;
{
}

- (void)executeDidChangeSectionDeleteHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex;
{
}

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath
{
}

- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath
{
}

- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath *)newIndexPath
{
}

- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath *)newIndexPath
{
}

@end
