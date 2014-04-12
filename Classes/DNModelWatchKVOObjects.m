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
           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    return [[DNModelWatchKVOObjects alloc] initWithModel:model andObjects:objects didChange:handler];
}

+ (id)watchWithModel:(DNModel*)model
          andObjects:(NSArray*)objects
       andAttributes:(NSArray*)attributes
           didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    return [[DNModelWatchKVOObjects alloc] initWithModel:model andObjects:objects andAttributes:attributes didChange:handler];
}

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)pObjects
          didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    return [self initWithModel:model andObjects:pObjects andAttributes:nil didChange:handler];
}

- (id)initWithModel:(DNModel*)model
         andObjects:(NSArray*)pObjects
      andAttributes:(NSArray*)pAttributes
          didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    self = [super initWithModel:model];
    if (self)
    {
        self.didChangeHandler   = handler;
        [self startWatch];

        objects     = pObjects;
        attributes  = pAttributes;
        
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
                  [object addObserver:self
                           forKeyPath:attributeName
                              options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                              context:nil];
              }];
         }];
        
        [self refreshWatch];
    }
    
    return self;
}

- (NSArray*)objects
{
    return objects;
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
    
    [self executeDidChangeHandler];
}

#pragma mark - NSKeyValueObserving protocol

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void *)context
{
    [self executeDidChangeHandler];
}

@end
