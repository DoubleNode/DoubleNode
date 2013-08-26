//
//  DNUIViewContainer.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/11/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNUITextField.h"

@interface DNUIViewContainer : NSObject

@property (nonatomic, retain) IBOutlet UIView*  view;

-(DNUIViewContainer*)initWithNibName:(NSString*)nibNameOrNil
                              bundle:(NSBundle*)nibBundleOrNil;

- (BOOL)textFieldShouldReturn_Default:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Done:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_EmergencyCall:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Go:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Google:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Join:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Next:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Route:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Search:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Send:(UITextField*)textField;
- (BOOL)textFieldShouldReturn_Yahoo:(UITextField*)textField;

@end
