//
//  DNBaseTheme.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/27/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNBaseTheme.h"

#import "UIFont+Custom.h"

@implementation DNBaseTheme

- (UIFont*)Font {   return [UIFont systemFontOfSize:[UIFont systemFontSize]];   }

- (NSNumber*)LabelKerning   {   return @1.0f;   }

- (UIColor*)BorderColor     {   return nil;     }
- (NSNumber*)BorderWidth    {   return @0.0f;   }

@end
