//
//  NSInvocation+Constructors.h
//  Phoenix
//
//  Created by Darren Ehlers on 5/23/14.
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (Constructors)

+ (id)invocationWithTarget:(NSObject*)targetObject
                  selector:(SEL)selector;

+ (id)invocationWithClass:(Class)targetClass
                 selector:(SEL)selector;

+ (id)invocationWithProtocol:(Protocol*)targetProtocol
                    selector:(SEL)selector;

@end
