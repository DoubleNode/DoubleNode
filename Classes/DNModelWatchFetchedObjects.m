//
//  DNModelWatchFetchedObjects.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNModelWatchFetchedObjects.h"

#import "DNCollectionView.h"
#import "UIView+Pending.h"

#import "DNModelWatchFetchedSection.h"

@interface DNModelWatchFetchedObjects () <NSFetchedResultsControllerDelegate>
{
    NSFetchRequest*             fetchRequest;
    NSFetchedResultsController* fetchResultsController;

    NSString*   sectionKeyPath;

    NSMutableArray* forcedSections;
}

@property (nonatomic, retain) DNCollectionView*     collectionView;

@end

@implementation DNModelWatchFetchedObjects

+ (id)watchWithModel:(DNModel*)model
            andFetch:(NSFetchRequest*)fetch
{
    return [[self class] watchWithModel:model andFetch:fetch groupBy:nil];
}

+ (id)watchWithModel:(DNModel*)model
            andFetch:(NSFetchRequest*)fetch
             groupBy:(NSString*)groupBy
{
    return [[DNModelWatchFetchedObjects alloc] initWithModel:model andFetch:fetch groupBy:groupBy];
}

+ (id)watchWithModel:(DNModel*)model
            andFetch:(NSFetchRequest*)fetch
   andCollectionView:(DNCollectionView*)collectionView
{
    return [[self class] watchWithModel:model andFetch:fetch groupBy:nil andCollectionView:collectionView];
}

+ (id)watchWithModel:(DNModel*)model
            andFetch:(NSFetchRequest*)fetch
             groupBy:(NSString*)groupBy
   andCollectionView:(DNCollectionView*)collectionView
{
    return [[DNModelWatchFetchedObjects alloc] initWithModel:model andFetch:fetch groupBy:groupBy andCollectionView:collectionView];
}

- (id)initWithModel:(DNModel*)model
           andFetch:(NSFetchRequest*)fetch
{
    return [self initWithModel:model andFetch:fetch groupBy:nil];
}

- (id)initWithModel:(DNModel*)model
           andFetch:(NSFetchRequest*)fetch
            groupBy:(NSString*)groupBy
{
    return [self initWithModel:model andFetch:fetch groupBy:groupBy andCollectionView:nil];
}

- (id)initWithModel:(DNModel*)model
           andFetch:(NSFetchRequest*)fetch
  andCollectionView:(DNCollectionView*)collectionView
{
    return [self initWithModel:model andFetch:fetch groupBy:nil andCollectionView:collectionView];
}

- (id)initWithModel:(DNModel*)model
           andFetch:(NSFetchRequest*)fetch
            groupBy:(NSString*)groupBy
  andCollectionView:(DNCollectionView*)collectionView
{
    self = [super initWithModel:model];
    if (self)
    {
        fetchRequest    = fetch;
        sectionKeyPath  = groupBy;
        
        self.collectionView = collectionView;
        if (self.collectionView && !self.collectionView.dataSource)
        {
            self.collectionView.dataSource  = self;
        }
        
        [self performWithContext:[[model class] managedObjectContext]
                    blockAndWait:^(NSManagedObjectContext* context)
         {
             NSAssert(context != nil, @"context is NIL");
             NSAssert(fetchRequest != nil, @"fetchRequest is NIL");
             
             fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:context
                                                                            sectionNameKeyPath:sectionKeyPath
                                                                                     cacheName:nil];    //NSStringFromClass([self class])];
         }];
        
        fetchResultsController.delegate = self;
    }
    
    return self;
}

- (NSArray*)sections
{
    if (forcedSections)
    {
        return forcedSections;
    }
    
    return fetchResultsController.sections;
}

- (id<NSFetchedResultsSectionInfo>)section:(NSUInteger)sectionNdx
{
    NSArray*    sections    = [self sections];
    if (!sections || ([sections count] <= sectionNdx))
    {
        return nil;
    }
    
    return sections[sectionNdx];
}

- (NSString*)sectionName:(NSUInteger)sectionNdx
{
    return [self section:sectionNdx].name;
}

- (NSString*)sectionIndexTitle:(NSUInteger)sectionNdx
{
    return [self section:sectionNdx].indexTitle;
}

- (NSArray*)objects
{
    if (forcedSections)
    {
        return [self objectsForSection:0];
    }

    return fetchResultsController.fetchedObjects;
}

- (NSArray*)objectsForSection:(NSUInteger)sectionNdx
{
    id<NSFetchedResultsSectionInfo> section = [self section:sectionNdx];
    if (!section)
    {
        return @[];
    }
    
    return section.objects;
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [fetchResultsController objectAtIndexPath:indexPath];
}

- (void)startWatch
{
    if ([self checkWatch])
    {
        return;
    }

    [super startWatch];

    [DNUtilities runOnBackgroundThread:
     ^()
     {
         [self performWithContext:[fetchResultsController managedObjectContext]
                            block:
          ^(NSManagedObjectContext* context)
          {
              [self refreshWatch];
              
              NSArray*   sections    = [self sections];
              
              forcedSections    = [NSMutableArray array];
              
              [sections enumerateObjectsUsingBlock:
               ^(id<NSFetchedResultsSectionInfo> obj, NSUInteger sectionNdx, BOOL* stop)
               {
                   [self executeWillChangeHandler:nil];
                   
                   NSMutableArray*  forcedObjects   = [NSMutableArray array];
                   
                   DNModelWatchFetchedSection*  forcedSection   = [[DNModelWatchFetchedSection alloc] init];
                   forcedSection.name               = obj.name;
                   forcedSection.indexTitle         = obj.indexTitle;
                   forcedSection.numberOfObjects    = obj.numberOfObjects;
                   forcedSection.objects            = forcedObjects;
                   
                   [forcedSections addObject:forcedSection];
                   
                   [self executeDidChangeSectionInsertHandler:forcedSection atIndex:sectionNdx context:nil];
                   
                   [self executeDidChangeHandler:nil];
                   
                   NSMutableArray*    arrayOfArrays = [NSMutableArray array];
                   
                   NSUInteger itemsRemaining = [obj.objects count];
                   NSUInteger j = 0;
                   
                   while (j < [obj.objects count])
                   {
                       NSRange    range       = NSMakeRange(j, MIN(30, itemsRemaining));
                       NSArray*   subarray    = [obj.objects subarrayWithRange:range];
                       
                       [arrayOfArrays addObject:subarray];
                       itemsRemaining -= range.length;
                       j += range.length;
                   }
                   
                   __block NSUInteger   objectNdx   = 0;
                   
                   [arrayOfArrays enumerateObjectsUsingBlock:
                    ^(NSArray* subObjects, NSUInteger idx, BOOL* stop)
                    {
                        [self executeWillChangeHandler:nil];
                        
                        [forcedObjects addObjectsFromArray:subObjects];
                        
                        [subObjects enumerateObjectsUsingBlock:
                         ^(id obj, NSUInteger idx2, BOOL* stop)
                         {
                             NSIndexPath*   indexPath   = [NSIndexPath indexPathForRow:objectNdx++ inSection:sectionNdx];
                             
                             [self executeDidChangeObjectInsertHandler:obj atIndexPath:indexPath newIndexPath:indexPath context:nil];
                         }];
                        
                        [self executeDidChangeHandler:nil];
                    }];
               }];
         
              forcedSections    = nil;
          }];
     }];
}

- (void)cancelWatch
{
    fetchRequest                    = nil;
    fetchResultsController.delegate = nil;
    fetchResultsController          = nil;
    
    if (self.collectionView)
    {
        DNCollectionView*   collectionView  = self.collectionView;
        
        self.collectionView = nil;
        
        [collectionView reloadData];
    }
    
    [super cancelWatch];
}

- (void)refreshWatch
{
    [super refreshWatch];
    
    fetchResultsController.fetchRequest.resultType = NSManagedObjectResultType;

    [self performWithContext:[fetchResultsController managedObjectContext]
                       block:^(NSManagedObjectContext* context)
     {
         NSError*    error = nil;

         BOOL   result = [fetchResultsController performFetch:&error];
         if (result == NO)
         {
             DLog(LL_Error, LD_CoreData, @"error=%@", [error localizedDescription]);
         }
     }];
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    if (self.numberOfItemsInSectionHandler)
    {
        return self.numberOfItemsInSectionHandler(self, collectionView, section);
    }
    
    return [self numberOfObjectsInSection:section];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSAssert(self.cellForItemAtIndexPathHandler, @"cellForItemAtIndexPathHandler required handler is not defined");
    return self.cellForItemAtIndexPathHandler(self, collectionView, indexPath);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    if (self.numberOfSectionsInCollectionViewHandler)
    {
        return self.numberOfSectionsInCollectionViewHandler(self, collectionView);
    }
    
    return [self numberOfSections];
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView
          viewForSupplementaryElementOfKind:(NSString*)kind
                                atIndexPath:(NSIndexPath*)indexPath
{
    NSAssert(self.viewForSupplementaryElementOfKindHandler, @"viewForSupplementaryElementOfKindHandler required handler is not defined");
    return self.viewForSupplementaryElementOfKindHandler(self, collectionView, kind, indexPath);
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    //NSLog(@"controllerWillChangeContent:");
    [self executeWillChangeHandler:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    //NSLog(@"controllerDidChangeContent:");
    [self executeDidChangeHandler:nil];
}

- (void)controller:(NSFetchedResultsController*)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    //NSLog(@"controller:didChangeSection:atIndex:%d forChangeType:", sectionIndex);
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            //NSLog(@"controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeInsert", sectionIndex);
            [self executeDidChangeSectionInsertHandler:sectionInfo atIndex:sectionIndex context:nil];
            break;
        }

        case NSFetchedResultsChangeDelete:
        {
            //NSLog(@"controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeDelete", sectionIndex);
            [self executeDidChangeSectionDeleteHandler:sectionInfo atIndex:sectionIndex context:nil];
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath*)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    //NSLog(@"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            //NSLog(@"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeInsert newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectInsertHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            //NSLog(@"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeDelete newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectDeleteHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }

        case NSFetchedResultsChangeUpdate:
        {
            //NSLog(@"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeUpdate newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            if ([self executeShouldChangeObjectUpdateHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil])
            {
                [self executeDidChangeObjectUpdateHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            }
            break;
        }

        case NSFetchedResultsChangeMove:
        {
            //NSLog(@"controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeMove newIndexPath:[%d:%d]", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectMoveHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }
    }
}

#pragma mark - Block Handler Calls

- (void)executeWillChangeHandler:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeWillChangeHandler [objects count]=%d", [[self objects] count]);
    if (self.collectionView)
    {
        [self.collectionView beginUpdates];
    }

    [super executeWillChangeHandler:context];
}

- (void)executeDidChangeHandler:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeDidChangeHandler [objects count]=%d", [[self objects] count]);
    if (self.collectionView)
    {
        [self.collectionView endUpdates];
    }

    [super executeDidChangeHandler:context];
}

- (void)executeDidChangeSectionInsertHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeDidChangeSectionInsertHandler:[%d] [objects[%d] count]=%d", sectionIndex, sectionIndex, [[self objectsForSection:sectionIndex] count]);
    if (self.collectionView)
    {
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
    }
    
    [super executeDidChangeSectionInsertHandler:sectionInfo
                                        atIndex:sectionIndex
                                        context:context];
}

- (void)executeDidChangeSectionDeleteHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeDidChangeSectionDeleteHandler:[%d] [objects[%d] count]=%d", sectionIndex, sectionIndex, [[self objectsForSection:sectionIndex] count]);
    if (self.collectionView)
    {
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
    }
    
    [super executeDidChangeSectionDeleteHandler:sectionInfo
                                        atIndex:sectionIndex
                                        context:context];
}

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeDidChangeObjectInsertHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, newIndexPath.section, [[self objectsForSection:newIndexPath.section] count]);
    if (self.collectionView)
    {
        [self.collectionView insertRowsAtIndexPaths:@[ newIndexPath ]];
    }

    [super executeDidChangeObjectInsertHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
}

- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeDidChangeObjectDeleteHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, indexPath.section, [[self objectsForSection:indexPath.section] count]);
    if (self.collectionView)
    {
        [self.collectionView deleteRowsAtIndexPaths:@[ indexPath ]];
    }

    [super executeDidChangeObjectDeleteHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
}

- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeDidChangeObjectUpdateHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, indexPath.section, [[self objectsForSection:indexPath.section] count]);
    if (self.collectionView)
    {
        [self.collectionView reloadRowsAtIndexPaths:@[ indexPath ]];
    }

    [super executeDidChangeObjectUpdateHandler:object
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
}

- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath*)newIndexPath
                                  context:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeDidChangeObjectMoveHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, indexPath.section, [[self objectsForSection:indexPath.section] count]);
    if (self.collectionView)
    {
        [self.collectionView moveRowAtIndexPath:indexPath
                                    toIndexPath:newIndexPath];
    }

    [super executeDidChangeObjectMoveHandler:object
                                 atIndexPath:indexPath
                                newIndexPath:newIndexPath
                                     context:context];
}

- (BOOL)executeShouldChangeObjectUpdateHandler:(id)object
                                   atIndexPath:(NSIndexPath*)indexPath
                                  newIndexPath:(NSIndexPath*)newIndexPath
                                       context:(NSDictionary*)context
{
    //NSLog(@"DNModelWatchFetchedObjects:executeShouldChangeObjectUpdateHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, indexPath.section, [[self objectsForSection:indexPath.section] count]);
    return [super executeShouldChangeObjectUpdateHandler:object
                                             atIndexPath:indexPath
                                            newIndexPath:newIndexPath
                                                 context:context];
}

@end
