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
}

@end

@implementation DNModelWatchKVOObject

+ (id)watchWithModel:(DNModel*)model
           andObject:(DNManagedObject*)object
           didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    return [[DNModelWatchKVOObject alloc] initWithModel:model andObject:object didChange:handler];
}

- (id)initWithModel:(DNModel*)model
          andObject:(DNManagedObject*)pObject
          didChange:(DNModelWatchObjectDidChangeHandlerBlock)handler
{
    self = [super initWithModel:model didChange:handler];
    if (self)
    {
        object  = pObject;
        
        [object addObserver:self
                 forKeyPath:@"key"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:nil];
        [object addObserver:self
                 forKeyPath:@"value"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:nil];
        
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
    
    [object removeObserver:self forKeyPath:@"key"];
    [object removeObserver:self forKeyPath:@"value"];
    
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
