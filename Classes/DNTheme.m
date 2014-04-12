//
//  DNTheme.h
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNTheme.h"

#import "UIFont+Custom.h"

@implementation DNTheme

- (UIFont*)Font {   return [UIFont systemFontOfSize:[UIFont systemFontSize]];   }

- (NSNumber*)LabelKerning   {   return @1.0f;   }

- (UIColor*)BorderColor     {   return nil;     }
- (NSNumber*)BorderWidth    {   return @0.0f;   }

@end
