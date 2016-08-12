//
//  DNModelWatchFetchedObjects.m
//  DoubleNode.com
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
    
    NSArray*    inProgressSections;
}

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
        if (self.collectionView && !self.collectionView.name)
        {
            DLog(LL_Error, LD_CoreData, @"Invalid Collection Name");
            DAssertIsMainThread
        }
        
        DAssertIsMainThread
        
        [self performWithContext:[[model class] managedObjectContext]
                    blockAndWait:^(NSManagedObjectContext* context)
         {
             NSAssert(context != nil, @"context is NIL");
             NSAssert(fetchRequest != nil, @"fetchRequest is NIL");
             
             DAssertIsMainThread
             
             fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:context
                                                                            sectionNameKeyPath:sectionKeyPath
                                                                                     cacheName:nil];    //NSStringFromClass([self class])];
        }];
        
        fetchResultsController.delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
    self.collectionView = nil;
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

    if (self.collectionView)
    {
        [self.collectionView reloadData];

        if (!self.collectionView.name)
        {
            DOLog(LL_Debug, LD_General, @"Nameless CollectionView! [%@]", NSStringFromSelector(_cmd));
        }
    }

    [super startWatch];

    //DOLog(LL_Debug, LD_General, @"[%@] startWatch - 1", self.name);
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
                   NSMutableArray*  forcedObjects   = [NSMutableArray array];

                   [DNUtilities runOnMainThreadWithoutDeadlocking:
                    ^()
                    {
                        //DOLog(LL_Debug, LD_General, @"[%@] startWatch - 2", self.name);
                        [self executeWillChangeHandler:nil];
                        
                        DNModelWatchFetchedSection*  forcedSection   = [[DNModelWatchFetchedSection alloc] init];
                        forcedSection.name               = obj.name;
                        forcedSection.indexTitle         = obj.indexTitle;
                        forcedSection.numberOfObjects    = obj.numberOfObjects;
                        forcedSection.objects            = forcedObjects;
                        
                        [forcedSections addObject:forcedSection];
                        
                        [self executeDidChangeSectionInsertHandler:forcedSection atIndex:sectionNdx context:nil];
                        
                        [self executeDidChangeHandler:nil];
                        //DOLog(LL_Debug, LD_General, @"[%@] startWatch - 3", self.name);
                    }];
                   
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
                        //DOLog(LL_Debug, LD_General, @"[%@] startWatch - 4", self.name);
                        [DNUtilities runOnMainThreadWithoutDeadlocking:
                         ^()
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
                             //DOLog(LL_Debug, LD_General, @"[%@] startWatch - 5", self.name);
                         }];
                    }];
               }];
         
              forcedSections    = nil;
              
              //DOLog(LL_Debug, LD_General, @"[%@] startWatch - 6", self.name);
          }];
     }];
}

- (void)cancelWatch
{
    DNCollectionView*   collectionView  = self.collectionView;

    self.collectionView = nil;

    fetchRequest                    = nil;
    fetchResultsController.delegate = nil;
    fetchResultsController          = nil;

    if (collectionView)
    {
        DAssertIsMainThread
        
        if (collectionView.dataSource)
        {
            [collectionView reloadData];
        }
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
             DLog(LL_Error, LD_CoreData, @"[%@] error=%@", self.name, [error localizedDescription]);
         }
     }];
}

- (void)pauseWatch
{
    if ([self isPaused])    {   return; }
    
    [super pauseWatch];
    
    [DNUtilities runOnMainThreadWithoutDeadlocking:
     ^()
     {
         fetchResultsController.delegate = nil;
         
         if (self.collectionView)
         {
             self.collectionView.paused = YES;
         }
     }];
}

- (void)resumeWatch
{
    if (![self isPaused])   {   return; }
    
    [super resumeWatch];
    
    [DNUtilities runOnMainThreadWithoutDeadlocking:
     ^()
     {
         if (self.collectionView)
         {
             [self.collectionView reloadData];
             self.collectionView.paused = NO;
         }
         
         fetchResultsController.delegate = self;
     }];
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSInteger   numberOfItems;
    
    if (self.numberOfItemsInSectionHandler)
    {
        numberOfItems = self.numberOfItemsInSectionHandler(self, collectionView, section);
    }
    else
    {
        numberOfItems = [self numberOfObjectsInSection:section];
    }
    
    //DOLog(LL_Debug, LD_General, @"[%@] numberOfItemsInSection: %d", self.name, numberOfItems);
    return numberOfItems;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
                 cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSAssert(self.cellForItemAtIndexPathHandler, @"cellForItemAtIndexPathHandler required handler is not defined");
    return self.cellForItemAtIndexPathHandler(self, collectionView, indexPath);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    NSInteger   numberOfSections;

    if (self.numberOfSectionsInCollectionViewHandler)
    {
        numberOfSections = self.numberOfSectionsInCollectionViewHandler(self, collectionView);
    }
    else
    {
        numberOfSections = [self numberOfSections];
    }
    
    //DOLog(LL_Debug, LD_General, @"[%@] numberOfSections: %d", self.name, numberOfSections);
    return numberOfSections;
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
    //DOLog(LL_Debug, LD_General, @"[%@] controllerWillChangeContent:", self.name);
    [self executeWillChangeHandler:nil];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    //DOLog(LL_Debug, LD_General, @"[%@] controllerDidChangeContent:", self.name);
    [self executeDidChangeHandler:nil];
}

- (void)controller:(NSFetchedResultsController*)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeSection:atIndex:%d forChangeType:", self.name, sectionIndex);
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeInsert", self.name, sectionIndex);
            [self executeDidChangeSectionInsertHandler:sectionInfo atIndex:sectionIndex context:nil];
            break;
        }

        case NSFetchedResultsChangeDelete:
        {
            //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeDelete", self.name, sectionIndex);
            [self executeDidChangeSectionDeleteHandler:sectionInfo atIndex:sectionIndex context:nil];
            break;
        }
            
        case NSFetchedResultsChangeMove:
        {
            //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeMove", self.name, sectionIndex);
            break;
        }
            
        case NSFetchedResultsChangeUpdate:
        {
            //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeSection:atIndex:%d forChangeType:NSFetchedResultsChangeUpdate", self.name, sectionIndex);
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
    //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:newIndexPath:[%d:%d]", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);

    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeInsert newIndexPath:[%d:%d]", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectInsertHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeDelete newIndexPath:[%d:%d]", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectDeleteHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }

        case NSFetchedResultsChangeUpdate:
        {
            //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeUpdate newIndexPath:[%d:%d]", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            if ([self executeShouldChangeObjectUpdateHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil])
            {
                [self executeDidChangeObjectUpdateHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            }
            break;
        }

        case NSFetchedResultsChangeMove:
        {
            //DOLog(LL_Debug, LD_General, @"[%@] controller:didChangeObject:atIndexPath:[%d:%d] forChangeType:NSFetchedResultsChangeMove newIndexPath:[%d:%d]", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self executeDidChangeObjectMoveHandler:anObject atIndexPath:indexPath newIndexPath:newIndexPath context:nil];
            break;
        }
    }
}

#pragma mark - Block Handler Calls

- (void)executeWillChangeHandler:(NSDictionary*)context
{
    DAssertIsMainThread
    
    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeWillChangeHandler [sections count]=%d [objects count]=%d", self.name, [[self sections] count], [[self objects] count]);
    for (int section = 0; section < [[self sections] count]; section++)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeWillChangeHandler - 2b [section:%d] objectCount=%d", self.name, section, [[self objectsForSection:section] count]);
    }

    if (self.collectionView)
    {
        if (!self.collectionView.window)
        {
            DOLog(LL_Debug, LD_General, @"CollectionView (%@) Not Visible! [%@]", self.collectionView.name, NSStringFromSelector(_cmd));
        }
        else
        {
            [self.collectionView beginUpdates];
        }
    }

    [super executeWillChangeHandler:context];
}

- (void)executeDidChangeHandler:(NSDictionary*)context
{
    DAssertIsMainThread

    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeHandler [sections count]=%d [objects count]=%d", self.name, [[self sections] count], [[self objects] count]);
    for (int section = 0; section < [[self sections] count]; section++)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeHandler - 2b [section:%d] objectCount=%d", self.name, section, [[self objectsForSection:section] count]);
    }

    if (self.collectionView)
    {
        if (!self.collectionView.window)
        {
            DOLog(LL_Debug, LD_General, @"CollectionView (%@) Not Visible! [%@]", self.collectionView.name, NSStringFromSelector(_cmd));
        }
        else
        {
            [self.collectionView endUpdates];
        }
    }
    
    [super executeDidChangeHandler:context];
}

- (void)executeDidChangeSectionInsertHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context
{
    DAssertIsMainThread
    
    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeSectionInsertHandler:[%d] [objects[%d] count]=%d", self.name, sectionIndex, sectionIndex, [[self objectsForSection:sectionIndex] count]);
    for (int section = 0; section < [[self sections] count]; section++)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeSectionInsertHandler - 2b [section:%d] objectCount=%d", self.name, section, [[self objectsForSection:section] count]);
    }
    
    if (self.collectionView)
    {
        if (!self.collectionView.window)
        {
            DOLog(LL_Debug, LD_General, @"CollectionView (%@) Not Visible! [%@]", self.collectionView.name, NSStringFromSelector(_cmd));
        }
        else
        {
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
        }
    }
    
    [super executeDidChangeSectionInsertHandler:sectionInfo
                                        atIndex:sectionIndex
                                        context:context];
}

- (void)executeDidChangeSectionDeleteHandler:(id <NSFetchedResultsSectionInfo>)sectionInfo
                                     atIndex:(NSUInteger)sectionIndex
                                     context:(NSDictionary*)context
{
    DAssertIsMainThread
    
    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeSectionDeleteHandler:[%d] [objects[%d] count]=%d", self.name, sectionIndex, sectionIndex, [[self objectsForSection:sectionIndex] count]);
    for (int section = 0; section < [[self sections] count]; section++)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeSectionDeleteHandler - 2b [section:%d] objectCount=%d", self.name, section, [[self objectsForSection:section] count]);
    }
    
    if (self.collectionView)
    {
        if (!self.collectionView.window)
        {
            DOLog(LL_Debug, LD_General, @"CollectionView (%@) Not Visible! [%@]", self.collectionView.name, NSStringFromSelector(_cmd));
        }
        else
        {
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
        }
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
    DAssertIsMainThread
    
    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeObjectInsertHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, newIndexPath.section, [[self objectsForSection:newIndexPath.section] count]);
    for (int section = 0; section < [[self sections] count]; section++)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeObjectInsertHandler - 2b [section:%d] objectCount=%d", self.name, section, [[self objectsForSection:section] count]);
    }
    
    if (self.collectionView)
    {
        if (!self.collectionView.window)
        {
            DOLog(LL_Debug, LD_General, @"CollectionView (%@) Not Visible! [%@]", self.collectionView.name, NSStringFromSelector(_cmd));
        }
        else
        {
            [self.collectionView insertRowsAtIndexPaths:@[ newIndexPath ]];
        }
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
    DAssertIsMainThread
    
    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeObjectDeleteHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, indexPath.section, [[self objectsForSection:indexPath.section] count]);
    for (int section = 0; section < [[self sections] count]; section++)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeObjectDeleteHandler - 2b [section:%d] objectCount=%d", self.name, section, [[self objectsForSection:section] count]);
    }
    
    if (self.collectionView)
    {
        if (!self.collectionView.window)
        {
            DOLog(LL_Debug, LD_General, @"CollectionView (%@) Not Visible! [%@]", self.collectionView.name, NSStringFromSelector(_cmd));
        }
        else
        {
            [self.collectionView deleteRowsAtIndexPaths:@[ indexPath ]];
        }
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
    DAssertIsMainThread
    
    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeObjectUpdateHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, indexPath.section, [[self objectsForSection:indexPath.section] count]);
    for (int section = 0; section < [[self sections] count]; section++)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeObjectUpdateHandler - 2b [section:%d] objectCount=%d", self.name, section, [[self objectsForSection:section] count]);
    }
    
    if (self.collectionView)
    {
        if (!self.collectionView.window)
        {
            DOLog(LL_Debug, LD_General, @"CollectionView (%@) Not Visible! [%@]", self.collectionView.name, NSStringFromSelector(_cmd));
        }
        else
        {
            [self.collectionView reloadRowsAtIndexPaths:@[ indexPath ]];
        }
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
    DAssertIsMainThread
    
    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeObjectMoveHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, indexPath.section, [[self objectsForSection:indexPath.section] count]);
    for (int section = 0; section < [[self sections] count]; section++)
    {
        //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeDidChangeObjectMoveHandler - 2b [section:%d] objectCount=%d", self.name, section, [[self objectsForSection:section] count]);
    }
    
    if (self.collectionView)
    {
        if (!self.collectionView.window)
        {
            DOLog(LL_Debug, LD_General, @"CollectionView (%@) Not Visible! [%@]", self.collectionView.name, NSStringFromSelector(_cmd));
        }
        else
        {
            [self.collectionView moveRowAtIndexPath:indexPath
                                        toIndexPath:newIndexPath];
        }
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
    DAssertIsMainThread
    
    //DOLog(LL_Debug, LD_General, @"[%@] DNModelWatchFetchedObjects:executeShouldChangeObjectUpdateHandler:[%d:%d] newIndexPath:[%d:%d] [objects[%d] count]=%d", self.name, indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row, indexPath.section, [[self objectsForSection:indexPath.section] count]);
    return [super executeShouldChangeObjectUpdateHandler:object
                                             atIndexPath:indexPath
                                            newIndexPath:newIndexPath
                                                 context:context];
}

@end
