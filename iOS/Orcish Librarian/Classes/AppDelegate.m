//
//  AppDelegate.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/19/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "AppDelegate.h"
#import "BasicSearchController.h"
#import "PriceListController.h"
#import "BookmarkController.h"
#import "CardViewController.h"
#import "CardSequence.h"
#import "GANTracker.h"


// ----------------------------------------------------------------------------
//  Private Methods
// ----------------------------------------------------------------------------

@interface AppDelegate () {
    CardViewController *queuedController;
}

- (void) initializeDatabase;
- (void) initializeSearchNames;
- (void) initializeWindow;
- (void) initializeAnalytics;
- (CardViewController *) dequeueCardViewController;

@end


// ----------------------------------------------------------------------------
//  Implementation
// ----------------------------------------------------------------------------

@implementation AppDelegate

@synthesize window;
@synthesize rootController;
@synthesize analyticsQueue;
@synthesize dbQueue;
@synthesize db;
@synthesize searchNames;

// ----------------------------------------------------------------------------

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.dbQueue = dispatch_queue_create("info.orcish.db.queue", NULL);
    self.analyticsQueue = dispatch_queue_create("info.orcish.analytics.queue", NULL);    
    dispatch_async(self.dbQueue, ^{ [self initializeDatabase]; });
    dispatch_async(self.dbQueue, ^{ [self initializeSearchNames]; });    
    [self initializeAnalytics];
    [self dequeueCardViewController];
    [self initializeWindow];    
    [self trackEvent:@"Application" action:@"Initialize" label:@""];
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
    [self.rootController pushViewController:controller animated:YES];
}

// ----------------------------------------------------------------------------

- (void) showCard:(Card *)card {
    [self showCards:[NSArray arrayWithObject:card] atPosition:0];    
}

// ----------------------------------------------------------------------------

- (void) showPriceModalForProductId:(NSString *)productId {
    PriceListController *controller = [[PriceListController alloc] initWithNibName:nil bundle:nil];
    [controller view];
    controller.productId = productId;
    [self.rootController presentModalViewController:controller animated:YES];
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

- (void) initializeAnalytics {
    dispatch_async(self.analyticsQueue, ^{ 
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSError *error;
        [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-18007072-1" dispatchPeriod:10 delegate:nil];
        [[GANTracker sharedTracker] setCustomVariableAtIndex:1 name:@"version" value:version withError:&error];    
    });
}

// ----------------------------------------------------------------------------

- (void) trackScreen:(NSString *)path {
    NSLog(@"TRACK SCREEN (%@)", path);
    dispatch_async(self.analyticsQueue, ^{ 
        NSError *error;
        [[GANTracker sharedTracker] trackPageview:path withError:&error];
    });

}

// ----------------------------------------------------------------------------

- (void) trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label {
    NSLog(@"TRACK EVENT (%@, %@, %@)", category, action, label);
    dispatch_async(self.analyticsQueue, ^{ 
        NSError *error;
        [[GANTracker sharedTracker] trackEvent:category action:action label:label value:0 withError:&error];
    });
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

- (void) showBookmarkController {
    [self hideMenu];
    BookmarkController *controller = [[BookmarkController alloc] init];
    [controller view];
    [self.rootController setViewController:controller animated:NO];
}

// ----------------------------------------------------------------------------

@end
