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

- (UIFont*)ButtonFont   {   return [UIFont customFontWithName:@"ProximaNova-Regular" size:18.0f];   }

- (NSNumber*)ButtonLabelKerning {   return @2.5f;    }

- (UIColor*)ButtonBorderColor   {   return [UIColor whiteColor];    }

- (NSNumber*)ButtonBorderWidth  {   return @1.0f;    }

- (NSNumber*)LOGWelcomeViewJustVisitingButtonLabelKerning   {   return @0.5f;    }
- (NSNumber*)LOGWelcomeViewJustVisitingButtonBorderWidth    {   return @0.0f;    }

@end
