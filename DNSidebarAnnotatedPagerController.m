//
//  DNSidebarAnnotatedPagerController.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/28/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import "DNSidebarAnnotatedPagerController.h"

#import "MZPImageViewController.h"

#import "MZPAppDelegate.h"

typedef enum
{
    DNScrollMode_none   = 0,
    DNScrollMode_title,
    DNScrollMode_view,
    DNScrollMode_catchup
}
DNScrollMode;

@interface DNSidebarAnnotatedPagerController ()
{
    DNScrollMode    scrollMode;
}
@end

@implementation DNSidebarAnnotatedPagerController

@synthesize scrollView, titleScrollView, alertView;
@synthesize bottomBar, bottomBar2, titleFadeView;

@dynamic pageIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            withTitle:(NSString*)title
      withRevealBlock:(RevealBlock)revealBlock
        withHideBlock:(RevealBlock)hideBlock
      withToggleBlock:(RevealBlock)toggleBlock
   withIsShowingBlock:(RevealBlock_Bool)isShowingBlock
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil
                        withTitle:title
                  withRevealBlock:revealBlock
                    withHideBlock:hideBlock
                  withToggleBlock:toggleBlock
               withIsShowingBlock:isShowingBlock];
    if (self)
    {
        self.titleControlHeight     = 44;
        self.titleColor             = [UIColor lightGrayColor];
        self.titleSelectedColor     = [UIColor whiteColor];
        self.titleBackgroundColor   = [UIColor darkGrayColor];
        self.indicatorBarColor      = [UIColor lightGrayColor];
        self.titleFontName          = @"";
        
        scrollMode  = DNScrollMode_none;
        
        _pageIndex  = 9999;
    }
    
    return self;
}

- (void)openAlertViewAnimated:(BOOL)animated
{
    CGRect  titleScrollViewFrame    = titleScrollView.frame;
    CGRect  scrollViewFrame         = scrollView.frame;
    
    CGRect  bottomBarFrame          = bottomBar.frame;
    CGRect  bottomBar2Frame         = bottomBar2.frame;
    CGRect  titleFadeViewFrame      = titleFadeView.frame;
    
    titleScrollViewFrame.origin.y   = 20;
    scrollViewFrame.origin.y        = 20 + self.titleControlHeight;
    scrollViewFrame.size.height     = self.view.bounds.size.height - self.titleControlHeight - 20;
    
    bottomBarFrame.origin.y     = 20 + self.titleControlHeight - 2.0f;
    bottomBar2Frame.origin.y    = 20 + self.titleControlHeight - 7.0f;
    titleFadeViewFrame.origin.y = 20;
    
    alertView.hidden    = NO;
    
    if (animated)
    {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseInOut
                         animations:^
         {
             titleScrollView.frame  = titleScrollViewFrame;
             scrollView.frame       = scrollViewFrame;
             bottomBar.frame        = bottomBarFrame;
             bottomBar2.frame       = bottomBar2Frame;
             titleFadeView.frame    = titleFadeViewFrame;
         }
                         completion:^(BOOL finished)
         {
             [self reloadPages];
         }];
    }
    else
    {
        titleScrollView.frame  = titleScrollViewFrame;
        scrollView.frame       = scrollViewFrame;
        bottomBar.frame        = bottomBarFrame;
        bottomBar2.frame       = bottomBar2Frame;
        titleFadeView.frame    = titleFadeViewFrame;
        
        [self reloadPages];
    }
}

- (void)closeAlertViewAnimated:(BOOL)animated
{
    CGRect  titleScrollViewFrame    = titleScrollView.frame;
    CGRect  scrollViewFrame         = scrollView.frame;
    
    CGRect  bottomBarFrame          = bottomBar.frame;
    CGRect  bottomBar2Frame         = bottomBar2.frame;
    CGRect  titleFadeViewFrame      = titleFadeView.frame;
    
    titleScrollViewFrame.origin.y   = 0;
    scrollViewFrame.origin.y        = self.titleControlHeight;
    scrollViewFrame.size.height     = self.view.bounds.size.height - self.titleControlHeight;

    bottomBarFrame.origin.y     = self.titleControlHeight - 2.0f;
    bottomBar2Frame.origin.y    = self.titleControlHeight - 7.0f;
    titleFadeViewFrame.origin.y = 0;
    
    if (animated)
    {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseInOut
                         animations:^
         {
             titleScrollView.frame  = titleScrollViewFrame;
             scrollView.frame       = scrollViewFrame;
             bottomBar.frame        = bottomBarFrame;
             bottomBar2.frame       = bottomBar2Frame;
             titleFadeView.frame    = titleFadeViewFrame;
         }
                         completion:^(BOOL finished)
         {
             alertView.hidden    = YES;
             
             [self reloadPages];
         }];
    }
    else
    {
        titleScrollView.frame  = titleScrollViewFrame;
        scrollView.frame       = scrollViewFrame;
        bottomBar.frame        = bottomBarFrame;
        bottomBar2.frame       = bottomBar2Frame;
        titleFadeView.frame    = titleFadeViewFrame;
        
        alertView.hidden    = YES;

        [self reloadPages];
    }
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = self.titleBackgroundColor;  // [UIColor scrollViewTexturedBackgroundColor];
    
    CGRect  frame       = CGRectMake(0, 0, self.view.bounds.size.width, self.titleControlHeight);
    //DLog(LL_Debug, @"colorView frame (%.2f, %.2f) - (%.2f, %.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    UIView* colorView   = [[UIView alloc] initWithFrame:frame];
    colorView.backgroundColor   = self.titleBackgroundColor;
    [self.view addSubview:colorView];

    //NSLog(@"self.view.bounds (%.2f, %.2f)", self.view.bounds.size.width, self.view.bounds.size.height);
    frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    alertView = [[UIView alloc] initWithFrame:frame];
    alertView.backgroundColor   = [UIColor colorWithRed:170.0f/256.0f green:0.0f blue:0.0f alpha:1.0f];
    UILabel*    alertLabel      = [[UILabel alloc] initWithFrame:frame];
    alertLabel.backgroundColor  = [UIColor clearColor];
    alertLabel.textColor        = [UIColor colorWithRed:204.0f/256.0f green:204.0f/256.0f blue:204.0f/256.0f alpha:1.0f];
    alertLabel.text             = @"No Internet Connection";
    alertLabel.textAlignment    = UITextAlignmentCenter;
    alertLabel.font             = [UIFont fontWithName:@"GothamLight" size:16.0f];
    alertLabel.font             = [alertLabel.font fontWithSize:16.0f];
    [alertView addSubview:alertLabel];

    frame = CGRectMake(self.view.bounds.size.width / 4, 0, self.view.bounds.size.width / 2.25, self.titleControlHeight);
    //NSLog(@"titleScrollView.frame (%.2f, %.2f) - (%.2f, %.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    titleScrollView = [[DNSpecialWidthScrollView alloc] initWithFrame:frame];
    titleScrollView.delegate    = self;
    titleScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    titleScrollView.responseInsets      = UIEdgeInsetsMake(0, self.view.bounds.size.width / 4, 0.0, self.view.bounds.size.width / 4);
    
    titleScrollView.backgroundColor                 = self.titleBackgroundColor;
    titleScrollView.canCancelContentTouches         = NO;
    titleScrollView.showsHorizontalScrollIndicator  = NO;
    
    titleScrollView.clipsToBounds   = NO;
    titleScrollView.scrollEnabled   = YES;
    titleScrollView.pagingEnabled   = YES;
    
    frame = CGRectMake(0, self.titleControlHeight, self.view.bounds.size.width, self.view.bounds.size.height - self.titleControlHeight);
    //NSLog(@"scrollView.frame (%.2f, %.2f) - (%.2f, %.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    scrollView.autoresizesSubviews              = YES;
    scrollView.backgroundColor                  = [UIColor clearColor];
    scrollView.canCancelContentTouches          = NO;
    scrollView.showsHorizontalScrollIndicator   = NO;
    scrollView.directionalLockEnabled           = YES;
    
    scrollView.clipsToBounds    = YES;
    scrollView.scrollEnabled    = YES;
    scrollView.pagingEnabled    = YES;
    
    [self.view addSubview:alertView];
    [self.view addSubview:scrollView];
    [self.view addSubview:titleScrollView];
    
    bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.titleControlHeight - 2.0f, self.view.bounds.size.width, 2.0f)];
    bottomBar.backgroundColor = self.indicatorBarColor;
    [self.view addSubview:bottomBar];
    
    NSInteger   width = self.view.bounds.size.width / 3;
    bottomBar2 = [[UIView alloc] initWithFrame:CGRectMake(width, self.titleControlHeight - 7.0f, width, 7.0f)];
    bottomBar2.backgroundColor = self.indicatorBarColor;
    [self.view addSubview:bottomBar2];
    
    titleFadeView   = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar-fade.png"]];
    titleFadeView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.titleControlHeight);
    [self.view addSubview:titleFadeView];
    
    //NSLog(@"self.view.bounds (%.2f, %.2f)", self.view.bounds.size.width, self.view.bounds.size.height);
    //NSLog(@"titleScrollView.frame (%.2f, %.2f) - (%.2f, %.2f)", titleScrollView.frame.origin.x, titleScrollView.frame.origin.y, titleScrollView.frame.size.width, titleScrollView.frame.size.height);
    //NSLog(@"scrollView.frame (%.2f, %.2f) - (%.2f, %.2f)", scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
    
    [self reloadPages];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    _lockPageChange = YES;
    [self reloadPages];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _lockPageChange = NO;
    [self setPageIndex:self.pageIndex animated:NO];
}

#pragma mark Add and remove
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0)
    {
        [self setPageIndexValue:0];
        for (UIViewController *vC in self.childViewControllers)
        {
            [vC willMoveToParentViewController:nil];
            [vC removeFromParentViewController];
        }
    }
    
    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         UIViewController *vC   = obj;
         
         [self addChildViewController:vC];
         [vC didMoveToParentViewController:self];
     }];

    [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (idx == 2)
         {
             UIViewController *vC   = obj;
          
             [vC.view.superview sendSubviewToBack:vC.view];
         }
     }];
    
    
    /*
    for (UIViewController *vC in viewControllers)
    {
        [self addChildViewController:vC];
        [vC didMoveToParentViewController:self];
    }
    */
    
    if (self.scrollView)
    {
        [self reloadPages];
    }
    //TODO animations
}

#pragma mark Properties
- (void)setPageIndexValue:(NSUInteger)pageIndexValue
{
    if (pageIndexValue == _pageIndex)
    {
        return;
    }
    
    NSUInteger          oldPageIndexValue   = _pageIndex;
    DNUIViewController* oldViewCtrlr        = nil;
    DNUIViewController* newViewCtrlr        = nil;
    
    if (oldPageIndexValue < [self.childViewControllers count])
    {
        oldViewCtrlr  = (DNUIViewController*)[self.childViewControllers objectAtIndex:oldPageIndexValue];
    }
    if (pageIndexValue < [self.childViewControllers count])
    {
        newViewCtrlr  = (DNUIViewController*)[self.childViewControllers objectAtIndex:pageIndexValue];
    }
    
    if (oldPageIndexValue != 9999)
    {
        NSLog(@"subViewWillDisappear:%d", oldPageIndexValue);
        if ([oldViewCtrlr respondsToSelector:@selector(subViewWillDisappear:)])
        {
            [oldViewCtrlr subViewWillDisappear:YES];
        }
    }
    if (pageIndexValue != 9999)
    {
        NSLog(@"subViewWillAppear:%d", pageIndexValue);
        if ([newViewCtrlr respondsToSelector:@selector(subViewWillAppear:)])
        {
            [newViewCtrlr subViewWillAppear:YES];
        }
        _pageIndex = pageIndexValue;
        NSLog(@"subViewDidAppear:%d", pageIndexValue);
        if ([newViewCtrlr respondsToSelector:@selector(subViewDidAppear:)])
        {
            [newViewCtrlr subViewDidAppear:YES];
        }
    }
    if (oldPageIndexValue != 9999)
    {
        NSLog(@"subViewDidDisappear:%d", oldPageIndexValue);
        if ([oldViewCtrlr respondsToSelector:@selector(subViewDidDisappear:)])
        {
            [oldViewCtrlr subViewDidDisappear:YES];
        }
    }
}

- (void)setPageIndex:(NSUInteger)pageIndex
{
    [self setPageIndex:pageIndex animated:NO];
}

- (void)setPageIndex:(NSUInteger)index animated:(BOOL)animated;
{
    [self setPageIndexValue:index];
    
    /*
     *	Change the scroll view
     */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    
    if (frame.origin.x < scrollView.contentSize.width)
    {
        scrollMode  = DNScrollMode_none;
        [scrollView scrollRectToVisible:frame animated:animated];
    }
    
    [self updateTitleColors:index];
}

- (NSUInteger)pageIndex
{
    return _pageIndex;
}

- (void)updateTitleColors:(NSUInteger)index
{
    for (UIView *view in titleScrollView.subviews)
    {
        for (UIView *view2 in view.subviews)
        {
            UIButton*   b = (UIButton*)view2;
            if (b.tag == index)
            {
                [b setTitleColor:self.titleSelectedColor forState:UIControlStateNormal];
            }
            else
            {
                [b setTitleColor:self.titleColor forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    //The scrollview tends to scroll to a different page when the screen rotates
    if (_lockPageChange)
        return;
    
    switch (scrollMode)
    {
        case DNScrollMode_title:
        {
            if (_scrollView != titleScrollView)
            {
                return;
            }
            break;
        }
            
        case DNScrollMode_view:
        {
            if (_scrollView != scrollView)
            {
                return;
            }
            break;
        }
            
        case DNScrollMode_catchup:
        {
            return;
        }
            
        default:
        case DNScrollMode_none:
        {
            if (_scrollView == titleScrollView)
            {
                scrollMode      = DNScrollMode_title;
            }
            else
            {
                scrollMode      = DNScrollMode_view;
            }
            break;
        }
    }

    switch (scrollMode)
    {
        case DNScrollMode_title:
        {
            //DLog(LL_Debug, @"titleScrollView (%.2f, %.2f)", titleScrollView.contentOffset.x, titleScrollView.contentOffset.y);
            
            CGFloat newXOff = (_scrollView.contentOffset.x * 2.25);
            if (newXOff > (scrollView.contentSize.width - scrollView.frame.size.width))
            {
                return;
            }
            //DLog(LL_Debug, @"newXOff (%.2f, %.2f)", newXOff, scrollView.contentSize.width);
            
            CGFloat pageWidth = _scrollView.frame.size.width;
            int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            [self setPageIndexValue:page];
            [self updateTitleColors:_pageIndex];
            
            //DLog(LL_Debug, @"moving scrollView (%.2f, %.2f)", newXOff, 0.0f);
            
            scrollView.contentOffset = CGPointMake(newXOff, 0);
            break;
        }
            
        case DNScrollMode_view:
        {
            //DLog(LL_Debug, @"scrollView (%.2f, %.2f)", scrollView.contentOffset.x, scrollView.contentOffset.y);
            
            /*
             *	We switch page at 50% across
             */
            CGFloat pageWidth = _scrollView.frame.size.width;
            int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            [self setPageIndexValue:page];
            [self updateTitleColors:_pageIndex];
            
            CGFloat newXOff = (_scrollView.contentOffset.x / 2.25);
            //DLog(LL_Debug, @"newXOff (%.2f)", newXOff);
            
            //DLog(LL_Debug, @"moving titleScrollView (%.2f, %.2f)", newXOff, 0.0f);
            
            titleScrollView.contentOffset = CGPointMake(newXOff, 0);
            break;
        }
            
        default:
        case DNScrollMode_none:
        case DNScrollMode_catchup:
        {
            break;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    scrollMode  = DNScrollMode_catchup;

    if (sender == titleScrollView)
    {
        //DLog(LL_Debug, @"stopped scrolling titleScrollView.contentOffset.x=%.2f", titleScrollView.contentOffset.x);
        
        // The key is repositioning without animation
        if (titleScrollView.contentOffset.x < 71)
        {
            [self setPageIndex:3];
            [titleScrollView setContentOffset:CGPointMake(426.5, 0) animated:NO];
/*
            [self updateTitleColors:3];
            [scrollView setContentOffset:CGPointMake(960, 0) animated:NO];
 */
            // Ended at index 3
            NSLog(@"ScreenGrab Index 3");
            [self screenGrabView:3 storeTo:0];
        }
        else if (titleScrollView.contentOffset.x < 213)
        {
            [self setPageIndex:1];
            [titleScrollView setContentOffset:CGPointMake(142, 0) animated:NO];
/*
            [self updateTitleColors:1];
            [scrollView setContentOffset:CGPointMake(320, 0) animated:NO];
 */
            // Ended at index 1
            NSLog(@"ScreenGrab Index 1");
            [self screenGrabView:1 storeTo:4];
        }
        else if (titleScrollView.contentOffset.x < 355.5)
        {
            [self setPageIndex:2];
            [titleScrollView setContentOffset:CGPointMake(284.5, 0) animated:NO];
/*
            [self updateTitleColors:2];
            [scrollView setContentOffset:CGPointMake(640, 0) animated:NO];
 */
            // Ended at index 2
            NSLog(@"ScreenGrab Index 2");
        }
        else if (titleScrollView.contentOffset.x < 497.5)
        {
            [self setPageIndex:3];
            [titleScrollView setContentOffset:CGPointMake(426.5, 0) animated:NO];
/*
            [self updateTitleColors:3];
            [scrollView setContentOffset:CGPointMake(960, 0) animated:NO];
 */
            // Ended at index 3
            NSLog(@"ScreenGrab Index 3");
            [self screenGrabView:3 storeTo:0];
        }
        else
        {
            [self setPageIndex:1];
            [titleScrollView setContentOffset:CGPointMake(142, 0) animated:NO];
/*
            [self updateTitleColors:1];
            [scrollView setContentOffset:CGPointMake(320, 0) animated:NO];
 */
            // Ended at index 1
            NSLog(@"ScreenGrab Index 1");
            [self screenGrabView:1 storeTo:4];
        }
    }
    else
    {
        //DLog(LL_Debug, @"stopped scrolling scrollView.contentOffset.x=%.2f", scrollView.contentOffset.x);

        // The key is repositioning without animation
        if (scrollView.contentOffset.x < 160)
        {
            [self setPageIndex:3];
            [titleScrollView setContentOffset:CGPointMake(426.5, 0) animated:NO];
/*
            [self updateTitleColors:3];
            [scrollView setContentOffset:CGPointMake(960, 0) animated:NO];
 */
            // Ended at index 3
            NSLog(@"ScreenGrab Index 3");
            [self screenGrabView:3 storeTo:0];
        }
        else if (scrollView.contentOffset.x < 480)
        {
            [self setPageIndex:1];
            [titleScrollView setContentOffset:CGPointMake(142, 0) animated:NO];
/*
            [self updateTitleColors:1];
            [scrollView setContentOffset:CGPointMake(320, 0) animated:NO];
 */
            // Ended at index 1
            NSLog(@"ScreenGrab Index 1");
            [self screenGrabView:1 storeTo:4];
        }
        else if (scrollView.contentOffset.x < 800)
        {
            [self setPageIndex:2];
            [titleScrollView setContentOffset:CGPointMake(284.5, 0) animated:NO];
/*
            [self updateTitleColors:2];
            [scrollView setContentOffset:CGPointMake(640, 0) animated:NO];
 */
            // Ended at index 2
            NSLog(@"ScreenGrab Index 2");
        }
        else if (scrollView.contentOffset.x < 1160)
        {
            [self setPageIndex:3];
            [titleScrollView setContentOffset:CGPointMake(426.5, 0) animated:NO];
/*
            [self updateTitleColors:3];
            [scrollView setContentOffset:CGPointMake(960, 0) animated:NO];
 */
            // Ended at index 3
            NSLog(@"ScreenGrab Index 3");
            [self screenGrabView:3 storeTo:0];
        }
        else
        {
            [self setPageIndex:1];
            [titleScrollView setContentOffset:CGPointMake(142, 0) animated:NO];
/*
            [self updateTitleColors:1];
            [scrollView setContentOffset:CGPointMake(320, 0) animated:NO];
 */
            // Ended at index 1
            NSLog(@"ScreenGrab Index 1");
            [self screenGrabView:1 storeTo:4];
        }
    }
    
    scrollMode  = DNScrollMode_none;
}

- (void)screenGrabView:(NSInteger)index storeTo:(NSInteger)destination
{
    UIImage*    screenGrab = [[self.childViewControllers objectAtIndex:index] imageOfView];

    MZPImageViewController* imageViewCtrlr  = (MZPImageViewController*)[self.childViewControllers objectAtIndex:destination];
    imageViewCtrlr.screenGrabImage.image    = screenGrab;
}

- (void)reloadPages
{
    for (UIView *view in titleScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    for (UIView *view in scrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
	CGFloat cx = 0;
    CGFloat titleItemWidth = titleScrollView.bounds.size.width;
    CGFloat dx = 0;
    
    NSUInteger count = self.childViewControllers.count;
	for (NSUInteger i = 0; i < count; i++)
    {
        UIViewController*   vC = [self.childViewControllers objectAtIndex:i];
        //NSLog(@"vC.view.frame (%.2f, %.2f) - (%.2f, %.2f)", vC.view.frame.origin.x, vC.view.frame.origin.y, vC.view.frame.size.width, vC.view.frame.size.height);
        
        CGRect  frame   = CGRectMake(dx, 0, titleItemWidth, titleScrollView.bounds.size.height);
        //DLog(LL_Debug, @"titleView frame (%.2f, %.2f) - (%.2f, %.2f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        UIView* view    = [[UIView alloc]initWithFrame:frame];
        view.autoresizingMask   = UIViewAutoresizingFlexibleWidth;
        view.backgroundColor    = self.titleBackgroundColor;
        
        UIFont* font = nil;
        if ([self.titleFontName length] > 0)
        {
            font = [UIFont fontWithName:self.titleFontName size:17.0f];
        }
        if (!font)
        {
            font = [UIFont boldSystemFontOfSize:17.0];
        }
        font = [font fontWithSize:17.0f];
        CGSize  size    = [vC.title sizeWithFont:font];
        if (([vC.title isEqualToString:@"MAP"] == YES) || ([vC.title isEqualToString:@"LIST"] == YES))
        {
            if ([[MZPAppDelegate appDelegate] isFilteredItemsDefault] == NO)
            {
                size.width  += 40.0f;
                size.height += 6.0f;
            }
        }
        
        frame = CGRectMake((frame.size.width - size.width)/1.70, 0.5*(frame.size.height - size.height), size.width, size.height);
        
        UIButton*   b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame     = frame;
        b.tag       = i;
        
        if (([vC.title isEqualToString:@"MAP"] == YES) || ([vC.title isEqualToString:@"LIST"] == YES))
        {
            if ([[MZPAppDelegate appDelegate] isFilteredItemsDefault] == NO)
            {
                UIImage*    image   = [UIImage imageNamed:@"menuicon-filter-mini"];
                
                b.imageEdgeInsets   = UIEdgeInsetsMake(2.0f, 4.0f, 6.0f, b.size.width - (image.size.width - 2.0f));
                b.titleEdgeInsets   = UIEdgeInsetsMake(0.0f, -10.0f, 0.0f, 0.0f);
                
                //b.imageEdgeInsets   = UIEdgeInsetsMake(-2.0f, b.size.width - image.size.width, 0.0f, 0.0f);
                //b.titleEdgeInsets   = UIEdgeInsetsMake(0.0f, -30.0f, 0.0f, 30.0f);
                
                [b setImage:image forState:UIControlStateNormal];
            }
        }
        
        b.backgroundColor       = [UIColor clearColor];
        // TODO: Doesn't work
        // b.titleLabel.textColor  = [UIColor blackColor];
        b.titleLabel.font       = font;
        
        [b setTitle:vC.title forState:UIControlStateNormal];
        [b addTarget:self action:@selector(didTapLabel:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:b];
        
        [titleScrollView addSubview:view];
        dx += titleItemWidth;
        
		CGRect  rect    = vC.view.frame;
		rect.origin.x   = cx;
		rect.origin.y   = 0;
        //rect.size.height    += 4;
        
		vC.view.frame  = rect;

        //NSLog(@"vC.view.frame (%.2f, %.2f) - (%.2f, %.2f)", vC.view.frame.origin.x, vC.view.frame.origin.y, vC.view.frame.size.width, vC.view.frame.size.height);
        //NSLog(@"scrollView.frame (%.2f, %.2f) - (%.2f, %.2f)", scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
		[scrollView addSubview:vC.view];
        //NSLog(@"scrollView.frame (%.2f, %.2f) - (%.2f, %.2f)", scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
        
        //NSLog(@"cx=%.2f sv.width=%.2f, vc.width=%.2f", cx, scrollView.frame.size.width, vC.view.frame.size.width);
		cx += scrollView.frame.size.width;
	}
	[titleScrollView setContentSize:CGSizeMake(dx+titleItemWidth/2.25, titleScrollView.bounds.size.height)];
	[titleScrollView setContentSize:CGSizeMake(dx, titleScrollView.bounds.size.height)];
    //NSLog(@"titleScrollView.frame (%.2f, %.2f) - (%.2f, %.2f)", titleScrollView.frame.origin.x, titleScrollView.frame.origin.y, titleScrollView.frame.size.width, titleScrollView.frame.size.height);
    //DLog(LL_Debug, @"titleView contentSize (%.2f, %.2f)", titleScrollView.contentSize.width, titleScrollView.contentSize.height);
	[scrollView setContentSize:CGSizeMake(cx, scrollView.bounds.size.height)];
    //NSLog(@"scrollView.contentSize (%.2f, %.2f)", scrollView.contentSize.width, scrollView.contentSize.height);
}

- (void)didTapLabel:(UIButton*)button
{
    [self setPageIndex:button.tag animated:YES];
}

@end
