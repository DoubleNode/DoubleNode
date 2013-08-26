//
//  DNSplitViewController.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 11/17/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "SplitViewController.h"

#import "MGTileMenuController.h"

@interface DNSidebarSplitViewController : SplitViewController <MGTileMenuDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MGTileMenuController* tileController;

- (id)initWithTitle:(NSString*)title
    withRevealBlock:(RevealBlock)revealBlock
      withHideBlock:(RevealBlock)hideBlock
    withToggleBlock:(RevealBlock)toggleBlock
 withIsShowingBlock:(RevealBlock_Bool)isShowingBlock;

- (void)revealSidebar;
- (void)hideSidebar;
- (void)toggleSidebar;
- (BOOL)isShowingSidebar;

- (NSString*)tilePhoneNumber;
- (NSString*)tileTwitterProfile;
- (NSString*)tileFacebookProfile;
- (NSString*)tileEmailSubject;
- (NSArray*)tileEmailToRecipients;
- (NSString*)tileEmailBodyDefault;
- (double)tileMapLatitude;
- (double)tileMapLongitude;
- (NSString*)tileMapLocation;
- (NSString*)tileWebsiteURL;

- (NSInteger)numberOfTilesInMenu:(MGTileMenuController *)tileMenu;
- (UIImage *)imageForTile:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu;
- (NSString *)labelForTile:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu;
- (NSString *)descriptionForTile:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu;
- (UIImage *)backgroundImageForTile:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu;
- (BOOL)isTileEnabled:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu;
- (void)tileMenu:(MGTileMenuController *)tileMenu didActivateTile:(NSInteger)tileNumber;

@end
