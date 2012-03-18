//
//  AppDelegate.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/19/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "AppDelegate.h"
#import "BasicSearchController.h"


// ----------------------------------------------------------------------------
//  Private Methods
// ----------------------------------------------------------------------------

@interface AppDelegate (Private)

- (void) initializeDatabase;
- (void) initializeSearchNames;
- (void) initializeWindow;

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
    BasicSearchController *basicSearchController = [[BasicSearchController alloc] initWithNibName:@"BasicSearchController" bundle:nil];
    [self.rootController view]; // force immediate NIB load
    [basicSearchController view]; // force immediate NIB load
    [self.rootController setViewController:basicSearchController animated:NO];
    [self.window makeKeyAndVisible];
}

// ----------------------------------------------------------------------------

@end
