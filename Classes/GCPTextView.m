//
// GCPTextView.m
// GCPTextView
//
// Created by Max on 9/27/13.
// Copyright (c) 2013 Green Cow Productions. All rights reserved.
//

// VERSION 0.2.1


#import <QuartzCore/QuartzCore.h>
#import "GCPTextView.h"



@implementation GCPTextView {

    NSString *_placeholder;
    UIColor *_placeholderColor;

    CATextLayer *_placeholderLayer;
    CGFloat _contentHeight;

    id <GCPTextViewDelegate> _otherDelegate;
}


- (void)setup {

    [super setDelegate: (id <UITextViewDelegate>) self];
    _contentHeight = 0;
}

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {

        [self setup];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {

        [self setup];
    }

    return self;
}

- (void)setPlaceholder:(NSString *)placeholder {

    _placeholder = [NSString stringWithString:placeholder];
    [self updatePlaceholderLayer];
    [self showPlaceholder];
}

- (NSString *)placeholder {

    return _placeholder;
}

- (void)setPlaceholderColor:(UIColor *)color {

    _placeholderColor = color;
    [self updatePlaceholderLayer];
}

- (UIColor *)placeholderColor {

    if (_placeholderColor)
        return _placeholderColor;

    return [UIColor colorWithWhite:0.7 alpha:1.0];
}

- (void)showPlaceholder {

    [self updatePlaceholderLayer];
    [[self placeholderLayer] setHidden:NO];
}

- (void)hidePlaceholder {

    [[self placeholderLayer] setHidden:YES];
}

- (BOOL)placeholderIsVisible {

    return [[self placeholderLayer] isHidden] == NO;
}

- (void)updatePlaceholderLayer {

    if ([self placeholder] == nil) {

        [[self placeholderLayer] setString:@""];
        return;
    }

    CGRect caretRect = [self caretRectForPosition:[self beginningOfDocument]];
    CGFloat width = self.frame.size.width - (2* caretRect.origin.x);
    CGRect rectForText = CGRectMake(caretRect.origin.x + caretRect.size.width, caretRect.origin.y + 1, width, self.frame.size.height);

    [[self placeholderLayer] setFrame:rectForText];
    [[self placeholderLayer] setForegroundColor:[[self placeholderColor] CGColor]];

    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[self font].fontName);

    [[self placeholderLayer] setFont:cgFont];
    [[self placeholderLayer] setFontSize:[[self font] pointSize]];
    [[self placeholderLayer] setString:[self placeholder]];

    switch ([self textAlignment]) {

        case NSTextAlignmentCenter:

            [[self placeholderLayer] setAlignmentMode:kCAAlignmentCenter];
            break;

        case NSTextAlignmentJustified:

            [[self placeholderLayer] setAlignmentMode:kCAAlignmentJustified];
            break;

        case NSTextAlignmentRight:

            [[self placeholderLayer] setAlignmentMode:kCAAlignmentRight];
            break;

        case NSTextAlignmentNatural:

            [[self placeholderLayer] setAlignmentMode:kCAAlignmentNatural];
            break;

        default:
            [[self placeholderLayer] setAlignmentMode:kCAAlignmentLeft];
            break;
    }
}

- (CATextLayer *)placeholderLayer {

    if (_placeholderLayer)
        return _placeholderLayer;

    _placeholderLayer = [CATextLayer layer];
    [_placeholderLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [self.layer addSublayer:_placeholderLayer];

    return _placeholderLayer;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {

    [super layoutSublayersOfLayer:layer];
    [self updatePlaceholderLayer];
}

- (void)updateContentHeight {

    CGFloat contentHeight = ceil([self sizeThatFits:self.frame.size].height);
    if (contentHeight != _contentHeight) {

        _contentHeight = contentHeight;

        if ([_otherDelegate respondsToSelector:@selector(textView:contentHeightDidChange:)]) {

            [_otherDelegate textView:self contentHeightDidChange:_contentHeight];
        }
    }
}

- (CGFloat)contentHeight {

    return _contentHeight;
}


#pragma mark -
#pragma mark Overridden TextView Methods

- (void)setDelegate:(id<GCPTextViewDelegate>)delegate {

    _otherDelegate = delegate;
}

- (void)setText:(NSString *)text {

    if ([text length] == 0)
        [self showPlaceholder];
    else
        [self hidePlaceholder];

    [super setText:text];
    [self updateContentHeight];
}

#pragma mark -
#pragma mark TextView Delegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    if (!_otherDelegate)
        return YES;

    if ([_otherDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
        return [_otherDelegate textViewShouldBeginEditing:textView];

    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

    if (!_otherDelegate)
        return;

    if ([_otherDelegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [_otherDelegate textViewDidBeginEditing:textView];
}

- (void)textViewDidChange:(UITextView *)textView {

    if ([textView.text length] == 0)
        [self showPlaceholder];
    else
        [self hidePlaceholder];

    [self updateContentHeight];

    if (!_otherDelegate)
        return;

    if ([_otherDelegate respondsToSelector:@selector(textViewDidChange:)])
        [_otherDelegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {

    if (!_otherDelegate)
        return;

    if ([_otherDelegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [_otherDelegate textViewDidChangeSelection:textView];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {

    if (!_otherDelegate)
        return YES;

    if ([_otherDelegate respondsToSelector:@selector(textViewShouldEndEditing:)])
        return [_otherDelegate textViewShouldEndEditing:textView];

    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {

    if (!_otherDelegate)
        return;

    if ([_otherDelegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [_otherDelegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    BOOL otherDelegateResult = YES;
    if (_otherDelegate) {

        if ([_otherDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
            otherDelegateResult = [_otherDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }

    if (otherDelegateResult == NO)
        return NO;

    if (([text length] > 0) && [self placeholderIsVisible]) {

        [self hidePlaceholder];
    }
    else if (([text length] == 0) && (range.location == 0)) {

        if ([self placeholderIsVisible]) {

            [_otherDelegate backspaceDidOccurInEmptyField];
        }
    }

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {

    if (!_otherDelegate)
        return YES;

    if ([_otherDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
        return [_otherDelegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {

    if (!_otherDelegate)
        return YES;

    if ([_otherDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
        return [_otherDelegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    
    return YES;
}

@end