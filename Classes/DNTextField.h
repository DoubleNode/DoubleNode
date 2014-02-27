//
//  DNTextField.h
//  Pods
//
//  Created by Darren Ehlers on 11/8/13.
//
//

#import <UIKit/UIKit.h>
#import <JustType/JustType.h>

@interface DNTextField : JTTextField

@property (nonatomic, assign) float verticalPadding;
@property (nonatomic, assign) float horizontalPadding;

- (void)shake;

@end
