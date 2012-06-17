//
//  AppDelegate.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/19/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "AppDelegate.h"
#import "BasicSearchController.h"
#import "AdvancedSearchController.h"
#import "PriceListController.h"
#import "BookmarkController.h"
#import "SetListController.h"
#import "CardViewController.h"
#import "AboutController.h"
#import "StaticCardSequence.h"
#import "RandomCardSequence.h"
#import "PriceManager.h"
#import "DataManager.h"
#import "ExternalSiteController.h"
#import "GANTracker.h"

#define kPriceCachePrunePeriod 120


typedef enum {
    kBasicSearch = 1,
    kAdvancedSearch = 2,
    kBrowseSets = 3,
    kBookmarks = 4,
    kRandomCards = 5,
    kAbout = 6
} TopLevelCategory;


// ----------------------------------------------------------------------------
//  Private Methods
// ----------------------------------------------------------------------------

@interface AppDelegate () {
    CardViewController *queuedController;
}

- (void) initializeData;
- (void) initializePriceCache;
- (void) initializeWindow;
- (CardViewController *) dequeueCardViewController;

@property (nonatomic, assign) TopLevelCategory topLevel;

@end


// ----------------------------------------------------------------------------
//  Implementation
// ----------------------------------------------------------------------------

@implementation AppDelegate

@synthesize window;
@synthesize rootController;
@synthesize dataQueue;
@synthesize topLevel;

// ----------------------------------------------------------------------------

- (NSString *) version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

// ----------------------------------------------------------------------------

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    dataQueue = dispatch_queue_create("info.orcish.db.queue", NULL);
    [self initializeData];
    [self dequeueCardViewController];
    [self initializeWindow];    
    [self initializePriceCache];
    return YES;
}

// ----------------------------------------------------------------------------

- (void) applicationDidBecomeActive:(UIApplication *)application {
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-18007072-2" dispatchPeriod:10 delegate:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [gDataManager updateFromServer];
    });
}

// ----------------------------------------------------------------------------

- (void) applicationDidEnterBackground:(UIApplication *)application {
    [[GANTracker sharedTracker] stopTracker];
}

// ----------------------------------------------------------------------------

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[PriceManager shared] clearCache];
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

- (void) launchExternalSite:(NSURL *)URL {
    ExternalSiteController *controller = [[ExternalSiteController alloc] initWithNibName:nil bundle:nil];
    [controller view];
    controller.URL = URL;
    [self.rootController presentModalViewController:controller animated:YES];
}

// ----------------------------------------------------------------------------

- (void) showCardList:(CardSequence *)sequence withTitle:(NSString *)title {
    OrcishSequenceController *controller = [[OrcishSequenceController alloc] initWithNibName:nil bundle:nil];
    [controller view];
    controller.sequence = sequence;
    controller.navigationItem.title = title;
    [self.rootController pushViewController:controller animated:YES];
}

// ----------------------------------------------------------------------------

- (void) showCards:(CardSequence *)sequence atPosition:(NSUInteger)position {    
    CardViewController *controller = [self dequeueCardViewController];
    controller.sequence = sequence;
    controller.position = position;
    [self.rootController pushViewController:controller animated:YES];
}

// ----------------------------------------------------------------------------

- (void) showCard:(Card *)card {    
    [self showCards:[[StaticCardSequence alloc] initWithCards:[NSArray arrayWithObject:card]] atPosition:0];    
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
    dispatch_async(gAppDelegate.dataQueue, ^{
        [gDataManager activateDataSources];
    });    
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

- (void) trackScreen:(NSString *)path {
    NSError *error;
    [[GANTracker sharedTracker] trackPageview:path withError:&error];
    // NSLog(@"Track Screen: %@", path);
}

// ----------------------------------------------------------------------------

- (void) trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label {
    NSError *error;
    [[GANTracker sharedTracker] trackEvent:category action:action label:label value:0 withError:&error];
    // NSLog(@"Track Event: %@, %@, %@", category, action, label);
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

- (void) clearCategory {
    self.topLevel = kNilOptions;
}

// ----------------------------------------------------------------------------

- (void) showRandomCardController {
    if (self.topLevel != kRandomCards) {
        self.topLevel = kRandomCards;
        CardViewController *controller = [self dequeueCardViewController];
        controller.sequence = [[RandomCardSequence alloc] init];
        controller.position = 0;
        [self.rootController setViewController:controller animated:NO];
    }
}

// ----------------------------------------------------------------------------

- (void) showBasicSearchController {
    if (self.topLevel != kBasicSearch) {
        self.topLevel = kBasicSearch;
        BasicSearchController *controller = [[BasicSearchController alloc] initWithNibName:nil bundle:nil];
        [self.rootController setViewController:controller animated:NO];
    }
}

// ----------------------------------------------------------------------------

- (void) showAdvancedSearchController {
    if (self.topLevel != kAdvancedSearch) {
        self.topLevel = kAdvancedSearch;
        AdvancedSearchController *controller = [[AdvancedSearchController alloc] initWithNibName:nil bundle:nil];
        [self.rootController setViewController:controller animated:NO];
    }
}

// ----------------------------------------------------------------------------

- (void) showBookmarkController {
    if (self.topLevel != kBookmarks) {
        self.topLevel = kBookmarks;
        BookmarkController *controller = [[BookmarkController alloc] initWithNibName:@"OrcishSequenceController" bundle:nil];
        [self.rootController setViewController:controller animated:NO];
    }
}

// ----------------------------------------------------------------------------

- (void) showBrowseController {
    if (self.topLevel != kBrowseSets) {
        self.topLevel = kBrowseSets;
        SetListController *controller = [[SetListController alloc] initWithNibName:nil bundle:nil];
        [self.rootController setViewController:controller animated:NO];
    }
}

// ----------------------------------------------------------------------------

- (void) showAboutController {
    if (self.topLevel != kAbout) {
        self.topLevel = kAbout;
        AboutController *controller = [[AboutController alloc] initWithNibName:nil bundle:nil];
        [self.rootController setViewController:controller animated:NO];
    }
}

// ----------------------------------------------------------------------------

@end
