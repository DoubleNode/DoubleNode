//
//  DNModelWatchKVOObject.m
//  Pods
//
//  Created by Darren Ehlers on 10/6/13.
//
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
           didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    return [[DNModelWatchKVOObject alloc] initWithModel:model andObject:object didChange:handler];
}

+ (id)watchWithModel:(DNModel*)model
           andObject:(DNManagedObject*)object
       andAttributes:(NSArray*)attributes
           didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    return [[DNModelWatchKVOObject alloc] initWithModel:model andObject:object andAttributes:attributes didChange:handler];
}

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)pObject
          didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    return [self initWithModel:model andObject:pObject andAttributes:nil didChange:handler];
}

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)pObject
      andAttributes:(NSArray*)pAttributes
          didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    self = [super initWithModel:model didChange:handler];
    if (self)
    {
        object      = pObject;
        attributes  = pAttributes;
        if (attributes == nil)
        {
            // Track ALL attributes
            attributes  = [[[object entityDescription] attributesByName] allKeys];
        }
        
        [attributes enumerateObjectsUsingBlock:^(NSString* attributeName, NSUInteger idx, BOOL *stop)
         {
             [object addObserver:self
                      forKeyPath:attributeName
                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                         context:nil];
         }];
        
        [self refreshWatch];
    }
    
    return self;
}

- (DNManagedObject*)object
{
    return object;
}

- (void)cancelWatch
{
    [super cancelWatch];
    
    [attributes enumerateObjectsUsingBlock:^(NSString* attributeName, NSUInteger idx, BOOL *stop)
     {
         [object removeObserver:self forKeyPath:attributeName];
     }];
    
    object  = nil;
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
