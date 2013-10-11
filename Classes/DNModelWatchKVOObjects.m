//
//  DNModelWatchKVOObjects.m
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
//

#import "DNModelWatchKVOObjects.h"

@interface DNModelWatchKVOObjects ()
{
    NSArray*        objects;
    NSDictionary*   attributes;
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
       andAttributes:(NSDictionary*)attributes
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
      andAttributes:(NSDictionary*)pAttributes
          didChange:(DNModelWatchObjectsDidChangeHandlerBlock)handler
{
    self = [super initWithModel:model didChange:handler];
    if (self)
    {
        objects     = pObjects;
        attributes  = pAttributes;
        
        [objects enumerateObjectsUsingBlock:^(DNManagedObject* object, NSUInteger idx, BOOL *stop)
         {
             NSDictionary*  objectAttributes = attributes;
             if (objectAttributes == nil)
             {
                 // Track ALL attributes
                 objectAttributes  = [[object entityDescription] attributesByName];
             }
             
             [attributes enumerateKeysAndObjectsUsingBlock:^(NSString* attributeName, id obj, BOOL* stop)
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
         NSDictionary*  objectAttributes = attributes;
         if (objectAttributes == nil)
         {
             // Track ALL attributes
             objectAttributes  = [[object entityDescription] attributesByName];
         }
         
         [attributes enumerateKeysAndObjectsUsingBlock:^(NSString* attributeName, id obj, BOOL* stop)
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
