//
//  OrcishViewController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/11/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "OrcishViewController.h"
#import "OrcishRootController.h"
#import "AppDelegate.h"


@interface OrcishViewController () {
    UIBarButtonItem *navigationButton;
}
    
@end


@implementation OrcishViewController

@dynamic navigationItem;
@synthesize parentViewController;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    navigationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu-Button"] 
        style:UIBarButtonItemStyleBordered target:self action:@selector(navigationButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:navigationButton];
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (gAppDelegate.rootController.controllerStack.count > 1) {
        navigationButton.image = [UIImage imageNamed:@"Back-Button"];
    } else {
        navigationButton.image = [UIImage imageNamed:@"Menu-Button"];
    }
}

// ----------------------------------------------------------------------------

- (void) navigationButtonTapped:(id)sender {
    if (gAppDelegate.rootController.controllerStack.count > 1) {
        [gAppDelegate trackEvent:@"Navigation" action:@"Back" label:@""];
        [gAppDelegate.rootController popViewControllerAnimated:YES];
    } else if (gAppDelegate.rootController.menuIsVisible) {
        [gAppDelegate.rootController hideMenu];
    } else {
        [gAppDelegate.rootController showMenu];
    }
}

// ----------------------------------------------------------------------------

@end
