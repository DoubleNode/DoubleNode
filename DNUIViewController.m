//
//  DNUIViewController.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/11/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#define DEBUGLOGGING
#import "DNUtilities.h"

#import "DNUIViewController.h"

@interface DNUIViewController ()
{
    BOOL    visibleFlag;
}
@end

@implementation DNUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil    = [DNUtilities appendNibSuffix:nibNameOrNil];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        visibleFlag = NO;
    }
    
    return self;
}

- (UIImage*)imageOfView;
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (BOOL)isVisible
{
    if (self.isViewLoaded && self.view.window)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isSubViewVisible
{
    return visibleFlag;
}

- (void)subViewWillAppear:(BOOL)animated
{
    
}

- (void)subViewDidAppear:(BOOL)animated
{
    visibleFlag = YES;
}

- (void)subViewWillDisappear:(BOOL)animated
{
    
}

- (void)subViewDidDisappear:(BOOL)animated
{
    visibleFlag = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign)
    {
        return NO;
    }
    
    switch (textField.returnKeyType)
    {
        case UIReturnKeyDefault:        {   return [self textFieldShouldReturn_Default:(UITextField *)textField];       }
        case UIReturnKeyDone:           {   return [self textFieldShouldReturn_Done:(UITextField *)textField];          }
        case UIReturnKeyEmergencyCall:  {   return [self textFieldShouldReturn_EmergencyCall:(UITextField *)textField]; }
        case UIReturnKeyGo:             {   return [self textFieldShouldReturn_Go:(UITextField *)textField];            }
        case UIReturnKeyGoogle:         {   return [self textFieldShouldReturn_Google:(UITextField *)textField];        }
        case UIReturnKeyJoin:           {   return [self textFieldShouldReturn_Join:(UITextField *)textField];          }
        case UIReturnKeyNext:           {   return [self textFieldShouldReturn_Next:(UITextField *)textField];          }
        case UIReturnKeyRoute:          {   return [self textFieldShouldReturn_Route:(UITextField *)textField];         }
        case UIReturnKeySearch:         {   return [self textFieldShouldReturn_Search:(UITextField *)textField];        }
        case UIReturnKeySend:           {   return [self textFieldShouldReturn_Send:(UITextField *)textField];          }
        case UIReturnKeyYahoo:          {   return [self textFieldShouldReturn_Yahoo:(UITextField *)textField];         }
    }

    return YES;
}

- (BOOL)textFieldShouldReturn_Default:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_Done:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_EmergencyCall:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_Go:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_Google:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_Join:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_Next:(UITextField*)textField
{
    UIView* nextField   = nil;
    if ([textField isKindOfClass:[DNUITextField class]])
    {
        DNUITextField*  dnTextField = (DNUITextField*)textField;
        
        nextField   = [dnTextField nextField];
    }
    if (nextField == nil)
    {
        UIView* nextView    = (UIView*)[self.view viewWithTag:(textField.tag + 1)];
        if (nextView != nil)
        {
            if ([nextView isKindOfClass:[UITextField class]])
            {
                nextField   = nextView;
            }
            else if ([nextView isKindOfClass:[UITextView class]])
            {
                nextField   = nextView;
            }
        }
    }
    if (nextField)
    {
        dispatch_async(dispatch_get_current_queue(), ^
                       {
                           [nextField becomeFirstResponder];
                       });
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn_Route:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_Search:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_Send:(UITextField*)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn_Yahoo:(UITextField*)textField
{
    return YES;
}

@end
