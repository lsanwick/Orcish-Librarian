//
//  AppDelegate.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/19/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishRootController.h"
#import "FMDatabase.h"

#define gAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@class CardViewController;
@class Card;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) OrcishRootController *rootController;
@property (nonatomic, readonly) dispatch_queue_t dataQueue;

- (void) hideKeyboard;
- (void) hideMenu;
- (void) showCardList:(NSArray *)cards withTitle:(NSString *)title;
- (void) showCards:(NSArray *)cards atPosition:(NSUInteger)position;
- (void) showCard:(Card *)card;
- (void) showPriceModalForProductId:(NSString *)productId;
- (void) launchExternalSite:(NSURL *)URL;

- (void) showBasicSearchController;
- (void) showBookmarkController;
- (void) showRandomCardController;
- (void) showBrowseController;
- (void) showAboutController;

- (void) trackScreen:(NSString *)path;
- (void) trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label;

@end
