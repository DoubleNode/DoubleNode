//
//  DNTextView.m
//  Gateway Church and DoubleNode.com
//
//  Copyright (c) 2014 Gateway Church. All rights reserved.
//
//  Derived from work originally created by Darren Ehlers
//  Portions Copyright (c) 2012 DoubleNode.com and Darren Ehlers.
//  All rights reserved.
//

#import "DNTextView.h"

@interface DNTextView()
{
    CGFloat _contentHeight;
}

@property (strong, nonatomic) UILabel* placeholderLabel;

@end

@implementation DNTextView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self defaultInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self defaultInit];
    }
    
    return self;
}

- (void)defaultInit
{
    _contentHeight  = 0;
    
    self.placeholderColor   = [UIColor colorWithWhite:0.700 alpha:1.000];
    
    CGRect caretRect        = [self caretRectForPosition:[self beginningOfDocument]];
    CGRect placeholderFrame = CGRectMake(caretRect.origin.x, caretRect.origin.y + 1, 0, 0);
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:placeholderFrame];
    self.placeholderLabel.font      = self.font;
    self.placeholderLabel.textColor = self.placeholderColor;
    
    [self addSubview:self.placeholderLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPlaceholder:(NSString*)placeholder
{
    if (![_placeholder isEqualToString:placeholder])
    {
        _placeholder = placeholder;
        
        self.placeholderLabel.text = placeholder;
        [self.placeholderLabel sizeToFit];
    }
}

- (void)setPlaceholderColor:(UIColor*)placeholderColor
{
    if (![_placeholderColor isEqual:placeholderColor])
    {
        _placeholderColor = placeholderColor;
        
        self.placeholderLabel.textColor = placeholderColor;
        [self.placeholderLabel sizeToFit];
    }
}

- (void)shake
{
    static int numberOfShakes = 4;

    CALayer*    layer   = [self layer];
    CGPoint     pos     = layer.position;

    CAKeyframeAnimation*    shakeAnimation  = [CAKeyframeAnimation animationWithKeyPath:NSStringFromSelector(@selector(position))];
    CGMutablePathRef        shakePath       = CGPathCreateMutable();

    CGPathMoveToPoint(shakePath, NULL, pos.x, pos.y);

    for (int index = 0; index < numberOfShakes; ++index)
    {
        CGPathAddLineToPoint(shakePath, NULL, pos.x - 8, pos.y);
        CGPathAddLineToPoint(shakePath, NULL, pos.x + 8, pos.y);
    }

    CGPathAddLineToPoint(shakePath, NULL, pos.x, pos.y);
    CGPathCloseSubpath(shakePath);

    shakeAnimation.timingFunction   = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    shakeAnimation.duration         = 1.2;
    shakeAnimation.path             = shakePath;

    [layer addAnimation:shakeAnimation forKey:nil];
}

- (void)textDidChange
{
    if (!self.text.length > 0)
    {
        self.placeholderLabel.hidden = NO;
    }
    else
    {
        self.placeholderLabel.hidden = YES;
    }
    
    [self updateContentHeight];
}

- (void)updateContentHeight
{
    CGFloat contentHeight = ceil([self sizeThatFits:self.frame.size].height);
    if (contentHeight != _contentHeight)
    {
        _contentHeight = contentHeight;
    }
}

- (CGFloat)contentHeight
{
    
    return _contentHeight;
}

// DME: Touches intercepted and forwarded to nextResponder and super to handle touched embedded links and data detector results
- (void)touchesBegan:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    [self.nextResponder touchesBegan:touches withEvent:event];

    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    [self.nextResponder touchesMoved:touches withEvent:event];

    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches
           withEvent:(UIEvent*)event
{
    [self.nextResponder touchesEnded:touches withEvent:event];

    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet*)touches
               withEvent:(UIEvent*)event
{
    [self.nextResponder touchesCancelled:touches withEvent:event];

    [super touchesCancelled:touches withEvent:event];
}

@end
