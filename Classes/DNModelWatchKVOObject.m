//
//  DNModelWatchKVOObject.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNModelWatchKVOObject.h"

@interface DNModelWatchKVOObject ()
{
    DNManagedObject*    object;
    NSArray*            attributes;
}

@end

@implementation DNModelWatchKVOObject

+ (id)watchWithModel:(DNModel*)model
           andObject:(DNManagedObject*)object
{
    return [[DNModelWatchKVOObject alloc] initWithModel:model andObject:object];
}

+ (id)watchWithModel:(DNModel*)model
           andObject:(DNManagedObject*)object
       andAttributes:(NSArray*)attributes
{
    return [[DNModelWatchKVOObject alloc] initWithModel:model andObject:object andAttributes:attributes];
}

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)pObject
{
    return [self initWithModel:model andObject:pObject andAttributes:nil];
}

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)pObject
      andAttributes:(NSArray*)pAttributes
{
    self = [super initWithModel:model];
    if (self)
    {
        object      = pObject;
        attributes  = pAttributes;
        
        self.name   = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(self.class), NSStringFromClass([object class])];
    }
    
    return self;
}

- (DNManagedObject*)object
{
    return object;
}

- (void)startWatch
{
    [super startWatch];

    if (attributes == nil)
    {
        // Track ALL attributes
        attributes  = [[[object entityDescription] attributesByName] allKeys];
    }

    NSArray*    localAttributes = [attributes copy];
    
    [localAttributes enumerateObjectsUsingBlock:
     ^(NSString* attributeName, NSUInteger idx, BOOL* stop)
     {
         NSUInteger initialFlag = ((idx == 0) ? NSKeyValueObservingOptionInitial : 0);

         [object addObserver:self
                  forKeyPath:attributeName
                     options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior | initialFlag
                     context:(__bridge void *)(attributeName)];
     }];
}

- (void)cancelWatch
{
    [super cancelWatch];

    NSArray*    localAttributes = [attributes copy];
    
    [localAttributes enumerateObjectsUsingBlock:
     ^(NSString* attributeName, NSUInteger idx, BOOL* stop)
     {
         @try
         {
             [object removeObserver:self forKeyPath:attributeName context:(__bridge void *)(attributeName)];
         }
         @catch (NSException* exception)
         {
             DLog(LL_Debug, LD_General, @"exception=%@", exception);
         }
     }];
    
    object      = nil;
    attributes  = nil;
}

- (void)refreshWatch
{
    [super refreshWatch];
    
    if (attributes == nil)
    {
        // Track ALL attributes
        attributes  = [[[object entityDescription] attributesByName] allKeys];
    }

    NSArray*    localAttributes = [attributes copy];
    
    [localAttributes enumerateObjectsUsingBlock:
     ^(NSString* attributeName, NSUInteger idx, BOOL* stop)
     {
         NSDictionary*  context = @{ @"keyPath" : attributeName };

         [self executeWillChangeHandler:context];
         
         [self executeDidChangeObjectUpdateHandler:[self object]
                                       atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                      newIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                           context:context];

         [self executeDidChangeHandler:context];
     }];
}

#pragma mark - execute Handler overrides

- (void)executeWillChangeHandler:(NSDictionary*)context
{
    [super executeWillChangeHandler:context];
}

- (void)executeDidChangeHandler:(NSDictionary*)context
{
    [super executeDidChangeHandler:context];
}

- (void)executeDidChangeObjectInsertHandler:(id)subjectObject
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    [super executeDidChangeObjectInsertHandler:subjectObject
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
}

- (void)executeDidChangeObjectDeleteHandler:(id)subjectObject
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    [super executeDidChangeObjectDeleteHandler:subjectObject
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
}

- (void)executeDidChangeObjectUpdateHandler:(id)subjectObject
                                atIndexPath:(NSIndexPath*)indexPath
                               newIndexPath:(NSIndexPath*)newIndexPath
                                    context:(NSDictionary*)context
{
    [super executeDidChangeObjectUpdateHandler:subjectObject
                                   atIndexPath:indexPath
                                  newIndexPath:newIndexPath
                                       context:context];
}

- (void)executeDidChangeObjectMoveHandler:(id)subjectObject
                              atIndexPath:(NSIndexPath*)indexPath
                             newIndexPath:(NSIndexPath*)newIndexPath
                                  context:(NSDictionary*)context
{
    [super executeDidChangeObjectMoveHandler:subjectObject
                                 atIndexPath:indexPath
                                newIndexPath:newIndexPath
                                     context:context];
}

#pragma mark - NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)subjectObject
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* DME-DEBUG CODE
    if ([NSStringFromClass([subjectObject class]) isEqualToString:@"CDOLesson"])
    {
        DOLog(LL_Debug, LD_General, @"KVO=CDOLesson, keyPath=%@", keyPath);
        if ([keyPath isEqualToString:@"notes"])
        {
            DOLog(LL_Debug, LD_General, @"KVO=CDOLesson, keyPath=%@", keyPath);
        }
    }
     */
    NSDictionary*   contextDictionary   = @{
                                            @"keyPath" : CFBridgingRelease(context),
                                            @"change"  : change
                                            };

    if ([change[NSKeyValueChangeNotificationIsPriorKey] isEqualToNumber:@YES])
    {
        [self executeWillChangeHandler:contextDictionary];
    }
    else
    {
        NSIndexPath*    indexPath   = [NSIndexPath indexPathForItem:0 inSection:0];
        
        switch ([change[NSKeyValueChangeKindKey] integerValue])
        {
            case NSKeyValueChangeSetting:
            {
                if ([change[NSKeyValueChangeNewKey] isEqual:change[NSKeyValueChangeOldKey]] == NO)
                {
                    [self executeDidChangeObjectUpdateHandler:subjectObject
                                                  atIndexPath:indexPath
                                                 newIndexPath:indexPath
                                                      context:contextDictionary];
                }
                break;
            }

            case NSKeyValueChangeInsertion:
            {
                [self executeDidChangeObjectInsertHandler:subjectObject
                                              atIndexPath:indexPath
                                             newIndexPath:indexPath
                                                  context:contextDictionary];
                break;
            }

            case NSKeyValueChangeRemoval:
            {
                [self executeDidChangeObjectDeleteHandler:subjectObject
                                              atIndexPath:indexPath
                                             newIndexPath:indexPath
                                                  context:contextDictionary];
                break;
            }

            case NSKeyValueChangeReplacement:
            {
                [self executeDidChangeObjectMoveHandler:subjectObject
                                            atIndexPath:indexPath
                                           newIndexPath:indexPath
                                                context:contextDictionary];
                break;
            }
        }

        [self executeDidChangeHandler:contextDictionary];
    }
}

@end
