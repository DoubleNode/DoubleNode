//
//  DNSidebarAnnotatedPagerController.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/28/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNSidebarViewController.h"

#import "DNSpecialWidthScrollView.h"
#import "SGViewPagerController.h"

@interface DNSidebarAnnotatedPagerController : DNSidebarViewController <UIScrollViewDelegate>
{
    NSUInteger  _pageIndex;
    BOOL        _lockPageChange;
}

@property (readonly, nonatomic) DNSpecialWidthScrollView*   titleScrollView;
@property (readonly, nonatomic) UIScrollView*               scrollView;
@property (readonly, nonatomic) UIView*                     alertView;
@property (readonly, nonatomic) UIView*                     bottomBar;
@property (readonly, nonatomic) UIView*                     bottomBar2;
@property (readonly, nonatomic) UIImageView*                titleFadeView;

@property (nonatomic) NSUInteger    pageIndex;
@property (nonatomic) NSUInteger    titleControlHeight;

@property (nonatomic) UIColor*      titleColor;
@property (nonatomic) UIColor*      titleSelectedColor;
@property (nonatomic) UIColor*      titleBackgroundColor;
@property (nonatomic) UIColor*      indicatorBarColor;

@property (nonatomic, retain) NSString* titleFontName;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            withTitle:(NSString*)title
      withRevealBlock:(RevealBlock)revealBlock
        withHideBlock:(RevealBlock)hideBlock
      withToggleBlock:(RevealBlock)toggleBlock
   withIsShowingBlock:(RevealBlock_Bool)isShowingBlock;

- (void)openAlertViewAnimated:(BOOL)animated;
- (void)closeAlertViewAnimated:(BOOL)animated;

- (void)reloadPages;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;//TODO animations
- (void)setPageIndex:(NSUInteger)index animated:(BOOL)animated;

@end
