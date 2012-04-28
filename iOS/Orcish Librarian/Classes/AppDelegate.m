//
//  AppDelegate.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/19/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "AppDelegate.h"
#import "BasicSearchController.h"
#import "CardViewController.h"
#import "CardSequence.h"
#import "Reachability.h"


// ----------------------------------------------------------------------------
//  Private Methods
// ----------------------------------------------------------------------------

@interface AppDelegate () {
    BOOL isOnline;
    CardViewController *queuedController;
}

- (void) initializeDatabase;
- (void) initializeSearchNames;
- (void) initializeWindow;
- (void) initializeNetworkStatus;
- (CardViewController *) dequeueCardViewController;

@end


// ----------------------------------------------------------------------------
//  Implementation
// ----------------------------------------------------------------------------

@implementation AppDelegate

@synthesize window;
@synthesize rootController;
@synthesize dbQueue;
@synthesize db;
@synthesize searchNames;

// ----------------------------------------------------------------------------

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.dbQueue = dispatch_queue_create("info.orcish.db.queue", NULL);
    dispatch_async(self.dbQueue, ^{ [self initializeDatabase]; });
    dispatch_async(self.dbQueue, ^{ [self initializeSearchNames]; });
    [self dequeueCardViewController];
    [self initializeNetworkStatus];
    [self initializeWindow];    
    return YES;
}

// ----------------------------------------------------------------------------

- (void) hideMenu {
    [(OrcishRootController *)(self.window.rootViewController) hideMenu];
}

// ----------------------------------------------------------------------------

- (void) hideKeyboard {
    [self.window.rootViewController.view endEditing:TRUE];
}

// ----------------------------------------------------------------------------

- (void) showCards:(NSArray *)cards atPosition:(NSUInteger)position {    
    CardViewController *controller = [self dequeueCardViewController];
    controller.sequence = [CardSequence sequenceWithCards:cards];
    controller.position = position;
    [gAppDelegate.rootController pushViewController:controller animated:YES];
}

// ----------------------------------------------------------------------------

- (void) showCard:(Card *)card {
    [self showCards:[NSArray arrayWithObject:card] atPosition:0];    
}

// ----------------------------------------------------------------------------

- (BOOL) isOnline {    
    return isOnline;
}

// ----------------------------------------------------------------------------

- (void) initializeSearchNames {
    NSString *readOnlyPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"card-names.txt"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *writablePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"card-names.txt"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    // -- FOR DEBUGGING: delete the file from its writable location every time
    if ([fm fileExistsAtPath:writablePath]) {
        [fm removeItemAtPath:writablePath error:&error];
    }
    // if the file hasn't been copied to a writable location, do that now
    if (![fm fileExistsAtPath:writablePath]) {
        if(![fm copyItemAtPath:readOnlyPath toPath:writablePath error:&error]) {
            NSAssert1(0, @"Failed to to copy card names: '%@'", [error localizedDescription]);
        }
    }
    self.searchNames = [NSData dataWithContentsOfFile:writablePath];
}

// ----------------------------------------------------------------------------

- (void) initializeDatabase {
    NSString *readOnlyPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cards.sqlite3"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *writablePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cards.sqlite3"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    // -- FOR DEBUGGING: delete the file from its writable location every time
    if ([fm fileExistsAtPath:writablePath]) {
        [fm removeItemAtPath:writablePath error:&error];
    }
    // if the file hasn't been copied to a writable location, do that now
    if (![fm fileExistsAtPath:writablePath]) {
        if(![fm copyItemAtPath:readOnlyPath toPath:writablePath error:&error]) {
            NSAssert1(0, @"Failed to to create database: '%@'", [error localizedDescription]);
        }
    }
    self.db = [FMDatabase databaseWithPath:writablePath];
    [self.db open];
}

// ----------------------------------------------------------------------------

- (void) initializeWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.rootController = [[OrcishRootController alloc] initWithNibName:nil bundle:nil];
    [self.rootController view]; // force immediate NIB load
    [self showBasicSearchController];
    [self.window makeKeyAndVisible];
}

// ----------------------------------------------------------------------------

- (void) initializeNetworkStatus {
    static dispatch_once_t once;
    static Reachability *reach = nil; 
    dispatch_once(&once, ^{ reach = [Reachability reachabilityForInternetConnection]; });
    reach.reachableBlock = ^(Reachability *reach) { isOnline = YES; };
    reach.unreachableBlock = ^(Reachability *reach) { isOnline = NO; };
}

// ----------------------------------------------------------------------------

- (CardViewController *) dequeueCardViewController {
    CardViewController *result = queuedController;
    dispatch_async(dispatch_get_main_queue(), ^{
        queuedController = [[CardViewController alloc] initWithNibName:nil bundle:nil];
        [queuedController view];
    });
    return result;
}

// ----------------------------------------------------------------------------

- (void) showRandomCardController {
    [self hideMenu];
    CardViewController *controller = [self dequeueCardViewController];
    controller.sequence = [CardSequence randomCardSequence];
    controller.position = 0;
    [self.rootController setViewController:controller animated:NO];
}

// ----------------------------------------------------------------------------

- (void) showBasicSearchController {
    [self hideMenu];
    BasicSearchController *controller = [[BasicSearchController alloc] initWithNibName:nil bundle:nil];
    [controller view];
    [self.rootController setViewController:controller animated:NO];
}

// ----------------------------------------------------------------------------

@end
