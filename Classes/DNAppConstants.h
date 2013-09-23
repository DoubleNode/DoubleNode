//
//  DNAppConstants.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNAppConstants : NSObject

+ (UIColor*)colorWithString:(NSString*)string;
+ (BOOL)boolWithString:(NSString*)string;
+ (double)doubleWithPreString:(NSString*)string;
+ (UIFont*)fontWithPreString:(NSString*)preString;
+ (CGSize)sizeWithPreString:(NSString*)preString;
+ (id)constantValue:(NSString*)key;

@end
