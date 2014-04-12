//
//  NSObject+PropertiesDictionary.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#include <objc/runtime.h>

#import "NSObject+PropertiesDictionary.h"

@implementation NSObject (PropertiesDictionary)

- (NSDictionary*)propertiesDictionary
{
    NSMutableDictionary*    props = [NSMutableDictionary dictionary];

    unsigned int    outCount;

    objc_property_t*    properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];

        NSString*   propertyName = [[NSString alloc] initWithCString:property_getName(property)];

        id  propertyValue = [self valueForKey:(NSString*)propertyName];
        if (propertyValue)
        {
            [props setObject:propertyValue forKey:propertyName];
        }

        /*
        // for all property attributes
        unsigned int    attributeCount = 0;

        objc_property_attribute_t*  attributes = property_copyAttributeList(property, &attributeCount);
        for (unsigned int attr = 0; attr < attributeCount; attr++)
        {
            NSLog(@"Attribute %d: name: %s, value: %s", attr, attributes[attr].name, attributes[attr].value);
        }
         */
    }

    free(properties);
    return props;
}

@end
