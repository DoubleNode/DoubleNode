//
//  DNSidebarViewController.m
//  DoubleNode.com
//
//  Created by Darren Ehlers on 10/11/12.
//  Copyright (c) 2012 DoubleNode.com. All rights reserved.
//

#define DEBUGLOGGING
#import "DNUtilities.h"

#import <MapKit/MapKit.h>

#import "DNSidebarViewController.h"

#import "YRDropdownView.h"

@interface DNSidebarViewController ()
{
    
@private
    RevealBlock         _revealBlock;
    RevealBlock         _hideBlock;
    RevealBlock         _toggleBlock;
    RevealBlock_Bool    _isShowingBlock;
}

@end

@implementation DNSidebarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
            withTitle:(NSString*)title
      withRevealBlock:(RevealBlock)revealBlock
        withHideBlock:(RevealBlock)hideBlock
      withToggleBlock:(RevealBlock)toggleBlock
   withIsShowingBlock:(RevealBlock_Bool)isShowingBlock
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.title  = [NSString stringWithFormat:@"%@", title];
        
        _revealBlock    = [revealBlock copy];
        _hideBlock      = [hideBlock copy];
        _toggleBlock    = [toggleBlock copy];
        _isShowingBlock = [isShowingBlock copy];
        
		self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuicon"]
                                             style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(toggleSidebar)];

        UIBarButtonItem*    contactBarButton =
            [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btnContact"]
                                             style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(openContactTileMenu)];
        [contactBarButton setTintColor:[UIColor blueColor]];
		self.navigationItem.rightBarButtonItem = contactBarButton;
    }
    
    return self;
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

#pragma mark - GHSidebarNav functions

- (void)revealSidebar
{
	_revealBlock(YES);
}

- (void)hideSidebar
{
	_hideBlock(YES);
}

- (void)toggleSidebar
{
	_toggleBlock(YES);
}

- (BOOL)isShowingSidebar
{
    return _isShowingBlock(YES);
}

- (void)toggleRightSidebar
{
	_toggleBlock(NO);
}

#pragma mark - tileMenu Contact Values

- (NSString*)tilePhoneNumber
{
    return [DNAppConstants contactPhoneNumber];
}

- (NSString*)tileTwitterProfile
{
    return [DNAppConstants contactTwitterProfile];
}

- (NSString*)tileFacebookProfile
{
    return [DNAppConstants contactFacebookProfile];
}

- (NSString*)tileEmailSubject
{
    return [DNAppConstants contactEmailSubject];
}

- (NSArray*)tileEmailToRecipients
{
    return [DNAppConstants contactEmailToRecipients];
}

- (NSString*)tileEmailBodyDefault
{
    return [DNAppConstants contactEmailBodyDefault];
}

- (double)tileMapLatitude
{
    return [DNAppConstants contactMapLatitude];
}

- (double)tileMapLongitude
{
    return [DNAppConstants contactMapLongitude];
}

- (NSString*)tileMapLocation
{
    return [DNAppConstants contactMapLocation];
}

- (NSString*)tileWebsiteURL
{
    return [DNAppConstants contactWebsiteURL];
}

#pragma mark - TileMenu delegate

- (void)openContactTileMenu
{
    return;
    
    if (!_tileController || (_tileController.isVisible == NO))
    {
        if (!_tileController)
        {
            // Create a tileController.
            _tileController = [[MGTileMenuController alloc] initWithDelegate:self];
            _tileController.dismissAfterTileActivated = YES;
        }
        
        // Display the TileMenu.
        [_tileController displayMenuCenteredOnPoint:self.view.center inView:self.view];
    }
}

- (NSInteger)numberOfTilesInMenu:(MGTileMenuController *)tileMenu
{
	return 6;
}

- (UIImage *)imageForTile:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu
{
	NSArray *images = [NSArray arrayWithObjects:
					   @"tilePhone",
					   @"tileEmail",
					   @"tileMap",
                       @"tileFacebook",
                       @"tileTwitter",
					   @"tileWebsite",
					   nil];
	if (tileNumber >= 0 && tileNumber < images.count)
    {
		return [UIImage imageNamed:[images objectAtIndex:tileNumber]];
	}
	
	return [UIImage imageNamed:@"Default Tile Image"];
}

- (NSString *)labelForTile:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu
{
	NSArray *labels = [NSArray arrayWithObjects:
					   @"Phone",
					   @"Email",
					   @"Location",
					   @"Facebook",
					   @"Twitter",
					   @"Website",
					   nil];
	if (tileNumber >= 0 && tileNumber < labels.count)
    {
		return [labels objectAtIndex:tileNumber];
	}
	
	return @"Default Label";
}

- (NSString *)descriptionForTile:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu
{
	NSArray *hints = [NSArray arrayWithObjects:
                      @"Call",
                      @"Send an Email",
                      @"Show where",
                      @"Facebook",
                      @"Tweet",
                      @"Check Out Website",
                      nil];
	if (tileNumber >= 0 && tileNumber < hints.count)
    {
		return [hints objectAtIndex:tileNumber];
	}
	
	return @"Default Description";
}

- (UIImage *)backgroundImageForTile:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu
{
    switch (tileNumber)
    {
            // Phone
        case 0:
        {
            return [UIImage imageNamed:@"red_gradient"];
        }
            
            // Email
        case 1:
        {
            return [UIImage imageNamed:@"purple_gradient"];
        }
            
            // Map
        case 2:
        {
            return [UIImage imageNamed:@"orange_gradient"];
        }
            
            // Facebook
        case 3:
        {
            return [UIImage imageNamed:@"darkblue_gradient"];
        }
            
            // Twitter
        case 4:
        {
            return [UIImage imageNamed:@"blue_gradient"];
        }
            
            // Website
        case 5:
        {
            return [UIImage imageNamed:@"yellow_gradient"];
        }
    }
    
    // return [UIImage imageNamed:@"purple_gradient"];
    // return [UIImage imageNamed:@"orange_gradient"];
    // return [UIImage imageNamed:@"red_gradient"];
    // return [UIImage imageNamed:@"yellow_gradient"];
    // return [UIImage imageNamed:@"green_gradient"];
    // return [UIImage imageNamed:@"grey_gradient"];
	
	return [UIImage imageNamed:@"grey_gradient"];
}

- (BOOL)isTileEnabled:(NSInteger)tileNumber inMenu:(MGTileMenuController *)tileMenu
{
    switch (tileNumber)
    {
            // Phone
        case 0:
        {
            if (![DNUtilities canDevicePlaceAPhoneCall])
            {
                return NO;
            }
            break;
        }
            
            // Email
        case 1:
        {
            if (![MFMailComposeViewController canSendMail])
            {
                return NO;
            }
            break;
        }
            
            // Map
        case 2:
        {
            break;
        }
            
            // Facebook
        case 3:
        {
            break;
        }
            
            // Twitter
        case 4:
        {
            break;
        }
            
            // Website
        case 5:
        {
            break;
        }
    }
	
	return YES;
}

- (void)tileMenu:(MGTileMenuController *)tileMenu didActivateTile:(NSInteger)tileNumber
{
	//NSLog(@"Tile %d activated (%@)", tileNumber, [self labelForTile:tileNumber inMenu:_tileController]);
    
    switch (tileNumber)
    {
            // Phone
        case 0:
        {
            NSString*   phoneNumber = [NSString stringWithFormat:@"telprompt:%@", [self tilePhoneNumber]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            break;
        }
            
            // Email
        case 1:
        {
            [self openMail];
            break;
        }
            
            // Map
        case 2:
        {
            [self openMap];
            break;
        }
            
            // Twitter
        case 3:
        {
            NSString*   twString    = [NSString stringWithFormat:@"twitter:@%@", [self tileTwitterProfile]];
            NSURL*      url         = [NSURL URLWithString:twString];
            
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
            else
            {
                twString = [NSString stringWithFormat:@"http://www.twitter.com/%@", [self tileTwitterProfile]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twString]];
            }
            break;
        }
            
            // Facebook
        case 4:
        {
            NSString*   fbString    = [NSString stringWithFormat:@"fb://profile/%@", [self tileFacebookProfile]];
            NSURL*      url         = [NSURL URLWithString:fbString];
            
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
            else
            {
                fbString = [NSString stringWithFormat:@"http://www.facebook.com/%@", [self tileFacebookProfile]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbString]];
            }
            break;
        }
            
            // Website
        case 5:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self tileWebsiteURL]]];
            break;
        }
    }
}

- (void)tileMenuDidDismiss:(MGTileMenuController *)tileMenu
{
	_tileController = nil;
}

- (void)openMap
{
    // Check for iOS 6
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D  coordinate = CLLocationCoordinate2DMake([self tileMapLatitude], [self tileMapLongitude]);

        MKPlacemark*    placemark   = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                            addressDictionary:nil];
        MKMapItem*      mapItem     = [[MKMapItem alloc] initWithPlacemark:placemark];
        
        [mapItem setName:[self tileMapLocation]];
        
        // Pass the map item to the Maps app
        [mapItem openInMapsWithLaunchOptions:nil];
    }
    else
    {
        NSString*   title       = [self tileMapLocation];
        float       latitude    = [self tileMapLatitude];
        float       longitude   = [self tileMapLongitude];
        
        int zoom = 13;
        
        NSString*   stringURL   = [NSString stringWithFormat:@"http://maps.google.com/maps?near=%@&ll=%1.6f,%1.6f&z=%d", title, latitude, longitude, zoom];
        stringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL*      url         = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Open the mail interface
- (void)openMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:[self tileEmailSubject]];
        [mailer setToRecipients:[self tileEmailToRecipients]];
        [mailer setMessageBody:[self tileEmailBodyDefault] isHTML:NO];
        
        // UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
        // NSData *imageData = UIImagePNGRepresentation(myImage);
        // [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
        
        if ([DNUtilities isDeviceIPad])
        {
            // only for iPad
            mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
}

#pragma mark - MFMailComposeController delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString*   msg;
    UIImage*    bgImage;
    UIImage*    iconImage;
    float       delay;
    
	switch (result)
	{
		case MFMailComposeResultCancelled:
        {
			msg         = @"Mail cancelled: you cancelled the operation and no email message was queued";
            bgImage     = [UIImage imageNamed:@"toast-bg"];
            iconImage   = [UIImage imageNamed:@"toast-alert"];
            delay       = 10.0f;
			break;
        }
            
		case MFMailComposeResultSaved:
        {
			msg         = @"Mail saved: you saved the email message in the Drafts folder";
            bgImage     = [UIImage imageNamed:@"toast-bg"];
            iconImage   = [UIImage imageNamed:@"toast-alert"];
            delay       = 10.0f;
			break;
        }
            
		case MFMailComposeResultSent:
        {
			msg         = @"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email";
            bgImage     = [UIImage imageNamed:@"toast-bg"];
            iconImage   = [UIImage imageNamed:@"toast-info"];
            delay       = 5;
			break;
        }
            
		case MFMailComposeResultFailed:
        {
			msg         = @"Mail failed: the email message was nog saved or queued, possibly due to an error";
            bgImage     = [UIImage imageNamed:@"toast-bg"];
            iconImage   = [UIImage imageNamed:@"toast-error"];
            delay       = 0.0f;
			break;
        }
            
		default:
        {
			msg         = @"Mail not sent";
            bgImage     = [UIImage imageNamed:@"toast-bg"];
            iconImage   = [UIImage imageNamed:@"toast-error"];
            delay       = 0.0f;
			break;
        }
	}
    
    [YRDropdownView showDropdownInView:self.view
                                 title:@"Sending an Email"
                                detail:msg
                                 image:iconImage
                       backgroundImage:bgImage
                       titleLabelColor:[UIColor colorWithWhite:1.0 alpha:1.0]
                      detailLabelColor:[UIColor colorWithWhite:1.0 alpha:1.0]
                              animated:YES
                             hideAfter:delay];
    
	[self dismissModalViewControllerAnimated:YES];
}

@end
