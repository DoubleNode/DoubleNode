//
//  DNModelWatchKVOObjects.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNModelWatchKVOObjects.h"

@interface DNModelWatchKVOObjects ()
{
    NSArray*    objects;
    NSArray*    attributes;
}

@end

@implementation DNModelWatchKVOObjects

+ (id)watchWithModel:(DNModel*)model
          andObjects:(NSArray*)objects
{
    return [[DNModelWatchKVOObjects alloc] initWithModel:model andObjects:objects];
}

+ (id)watchWithModel:(DNModel*)model
          andObjects:(NSArray*)objects
       andAttributes:(NSArray*)attributes
{
    return [[DNModelWatchKVOObjects alloc] initWithModel:model andObjects:objects andAttributes:attributes];
}

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)pObjects
{
    return [self initWithModel:model andObjects:pObjects andAttributes:nil];
}

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)pObjects
      andAttributes:(NSArray*)pAttributes
{
    self = [super initWithModel:model];
    if (self)
    {
        objects     = pObjects;
        attributes  = pAttributes;
    }
    
    return self;
}

- (NSArray*)objects
{
    return objects;
}

- (void)startWatch
{
    [super startWatch];

    [objects enumerateObjectsUsingBlock:^(DNManagedObject* object, NSUInteger idx, BOOL *stop)
     {
         NSArray*  objectAttributes = attributes;
         if (objectAttributes == nil)
         {
             // Track ALL attributes
             objectAttributes  = [[[object entityDescription] attributesByName] allKeys];
         }

         [attributes enumerateObjectsUsingBlock:^(NSString* attributeName, NSUInteger idx, BOOL *stop)
          {
              NSUInteger initialFlag = ((idx == 0) ? NSKeyValueObservingOptionInitial : 0);

              [object addObserver:self
                       forKeyPath:attributeName
                          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior | initialFlag
                          context:nil];
          }];
     }];
}

- (void)cancelWatch
{
    [super cancelWatch];

    [objects enumerateObjectsUsingBlock:^(DNManagedObject* object, NSUInteger idx, BOOL *stop)
     {
         NSArray*  objectAttributes = attributes;
         if (objectAttributes == nil)
         {
             // Track ALL attributes
             objectAttributes  = [[[object entityDescription] attributesByName] allKeys];
         }
         
         [attributes enumerateObjectsUsingBlock:^(NSString* attributeName, NSUInteger idx, BOOL *stop)
          {
              [object removeObserver:self forKeyPath:attributeName];
          }];
     }];
    
    objects = nil;
}

- (void)refreshWatch
{
    [super refreshWatch];
    
    [objects enumerateObjectsUsingBlock:^(DNManagedObject* object, NSUInteger idx, BOOL *stop)
     {
         [self executeWillChangeHandler];

         [self executeDidChangeObjectUpdateHandler:object
                                       atIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]
                                      newIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];

         [self executeDidChangeHandler];
     }];
}

#pragma mark - execute Handler overrides

- (void)executeWillChangeHandler
{
    [DNUtilities runOnBackgroundThread:^
     {
         [super executeWillChangeHandler];
     }];
}

- (void)executeDidChangeHandler
{
    [DNUtilities runOnBackgroundThread:^
     {
         [super executeDidChangeHandler];
     }];
}

- (void)executeDidChangeObjectInsertHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
{
    [DNUtilities runOnBackgroundThread:^
     {
         [super executeDidChangeObjectInsertHandler:object
                                        atIndexPath:indexPath
                                       newIndexPath:newIndexPath];
     }];
}

- (void)executeDidChangeObjectDeleteHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
{
    [DNUtilities runOnBackgroundThread:^
     {
         [super executeDidChangeObjectDeleteHandler:object
                                        atIndexPath:indexPath
                                       newIndexPath:newIndexPath];
     }];
}

- (void)executeDidChangeObjectUpdateHandler:(id)object
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
{
    [DNUtilities runOnBackgroundThread:^
     {
         [super executeDidChangeObjectUpdateHandler:object
                                        atIndexPath:indexPath
                                       newIndexPath:newIndexPath];
     }];
}

- (void)executeDidChangeObjectMoveHandler:(id)object
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath*)newIndexPath
{
    [DNUtilities runOnBackgroundThread:^
     {
         [super executeDidChangeObjectMoveHandler:object
                                      atIndexPath:indexPath
                                     newIndexPath:newIndexPath];
     }];
}

#pragma mark - NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)subjectObject
                        change:(NSDictionary*)change
                       context:(void *)context
{
    if ([change[NSKeyValueChangeNotificationIsPriorKey] isEqualToNumber:@YES])
    {
        [self executeWillChangeHandler];
    }
    else
    {
        NSUInteger      idx         = [[self objects] indexOfObject:subjectObject];
        NSIndexPath*    indexPath   = [NSIndexPath indexPathForItem:idx inSection:0];

        switch ([change[NSKeyValueChangeKindKey] integerValue])
        {
            case NSKeyValueChangeSetting:
            {
                if ([change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]] == NO)
                {
                    [self executeDidChangeObjectUpdateHandler:subjectObject
                                                  atIndexPath:indexPath
                                                 newIndexPath:indexPath];
                }
                break;
            }

            case NSKeyValueChangeInsertion:
            {
                [self executeDidChangeObjectInsertHandler:subjectObject
                                              atIndexPath:indexPath
                                             newIndexPath:indexPath];
                break;
            }

            case NSKeyValueChangeRemoval:
            {
                [self executeDidChangeObjectDeleteHandler:subjectObject
                                              atIndexPath:indexPath
                                             newIndexPath:indexPath];
                break;
            }

            case NSKeyValueChangeReplacement:
            {
                [self executeDidChangeObjectMoveHandler:subjectObject
                                            atIndexPath:indexPath
                                           newIndexPath:indexPath];
                break;
            }
        }

        [self executeDidChangeHandler];
    }
}

@end
