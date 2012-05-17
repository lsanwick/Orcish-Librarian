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
#import "SetListController.h"
#import "CardViewController.h"
#import "CardSequence.h"
#import "PriceManager.h"
#import "DataManager.h"
#import "GANTracker.h"

#define kPriceCachePrunePeriod 120


// ----------------------------------------------------------------------------
//  Private Methods
// ----------------------------------------------------------------------------

@interface AppDelegate () {
    CardViewController *queuedController;
}

- (void) initializeData;
- (void) initializePriceCache;
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
@synthesize dataQueue;
@synthesize db;
@synthesize searchNames;

// ----------------------------------------------------------------------------

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.dataQueue = dispatch_queue_create("info.orcish.db.queue", NULL);
    self.analyticsQueue = dispatch_queue_create("info.orcish.analytics.queue", NULL);    
    dispatch_async(self.dataQueue, ^{ [self initializeData]; });
    [self initializeAnalytics];
    [self dequeueCardViewController];
    [self initializeWindow];    
    [self initializePriceCache];
    [self trackEvent:@"Application" action:@"Initialize" label:@""];
    return YES;
}

// ----------------------------------------------------------------------------

- (void) applicationDidBecomeActive:(UIApplication *)application {
    [[DataManager shared] stageUpdatesFromServer];
}

// ----------------------------------------------------------------------------

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[PriceManager shared] clearCache];
    // TODO: wipe search-names text from memory (needs to reload later if absent).
    //       alternatively, could memory-map the data (mmap or NSData)?
}

// ----------------------------------------------------------------------------

- (NSString *) databaseVersion {
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"databaseVersion"];
    return version ? version : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

// ----------------------------------------------------------------------------

- (void) setDatabaseVersion:(NSString *)databaseVersion {
    [[NSUserDefaults standardUserDefaults] setObject:databaseVersion forKey:@"databaseVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void) showCardList:(NSArray *)cards withTitle:(NSString *)title {
    OrcishViewController *controller = [[OrcishViewController alloc] initWithNibName:nil bundle:nil];
    [controller view];
    controller.cardList = cards;
    controller.navigationItem.title = title;
    [self.rootController pushViewController:controller animated:YES];
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

- (void) initializePriceCache {
    [[PriceManager shared] loadCache];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, kPriceCachePrunePeriod * NSEC_PER_SEC), kPriceCachePrunePeriod * NSEC_PER_SEC, kPriceCachePrunePeriod * 0.5 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [[PriceManager shared] pruneCache];
        [[PriceManager shared] saveCache];
    });
    dispatch_resume(timer);
}

// ----------------------------------------------------------------------------

- (void) initializeData {
    DataManager *dataManager = [DataManager shared];
    if ([dataManager hasStagedUpdates]) {
        [dataManager installDataFromStage];
    } else if(![dataManager hasInstalledData]) {
        [dataManager installDataFromBundle];
    } else {
    }
    [self activateDataSources];    
}

// ----------------------------------------------------------------------------

- (void) activateDataSources {
    NSError *error;
    DataManager *dataManager = [DataManager shared];
    self.searchNames = [NSData dataWithContentsOfFile:dataManager.cardNamesTextPath options:NSDataReadingMappedAlways error:&error];
    self.db = [FMDatabase databaseWithPath:dataManager.databasePath];
    [self.db open];
}

// ----------------------------------------------------------------------------

- (void) deactivateDataSources {
    [self.db close];
    self.db = nil;
    self.searchNames = nil;
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
    // NSLog(@"TRACK SCREEN (%@)", path);
    dispatch_async(self.analyticsQueue, ^{ 
        NSError *error;
        [[GANTracker sharedTracker] trackPageview:path withError:&error];
    });

}

// ----------------------------------------------------------------------------

- (void) trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label {
    // NSLog(@"TRACK EVENT (%@, %@, %@)", category, action, label);
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
    BookmarkController *controller = [[BookmarkController alloc] initWithNibName:@"OrcishViewController" bundle:nil];
    [controller view];
    controller.navigationItem.title = @"Bookmarks";
    [self.rootController setViewController:controller animated:NO];
}

// ----------------------------------------------------------------------------

- (void) showBrowseController {
    [self hideMenu];
    SetListController *controller = [[SetListController alloc] initWithNibName:nil bundle:nil];
    [controller view];
    [self.rootController setViewController:controller animated:NO];
}

// ----------------------------------------------------------------------------

@end
