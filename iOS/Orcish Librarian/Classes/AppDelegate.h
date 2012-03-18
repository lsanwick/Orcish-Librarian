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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OrcishRootController *rootController;
@property (assign, nonatomic) dispatch_queue_t dbQueue;
@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSData *searchNames;

- (void) hideKeyboard;
- (void) hideMenu;

@end
