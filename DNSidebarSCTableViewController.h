//
//  DNSidebarSCTable.h
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/11/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <SensibleTableView/SensibleTableView.h>

#import "DNUtilities.h"

#import "MGTileMenuController.h"

@interface DNSidebarSCTableViewController : SCTableViewController <MGTileMenuDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MGTileMenuController* tileController;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            withTitle:(NSString*)title
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
