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
@property (nonatomic, assign) dispatch_queue_t dbQueue;
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSData *searchNames;
@property (nonatomic, readonly) BOOL isOnline;

- (void) hideKeyboard;
- (void) hideMenu;
- (void) showCards:(NSArray *)cards atPosition:(NSUInteger)position;
- (void) showCard:(Card *)card;

@end
