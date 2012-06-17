//
//  OrcishViewController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/16/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "OrcishViewController.h"
#import "AppDelegate.h"

@interface OrcishViewController () {
    UIBarButtonItem *navigationButton;
}

@end

@implementation OrcishViewController

@dynamic navigationItem;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    navigationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu-Button"] 
        style:UIBarButtonItemStyleBordered target:self action:@selector(navigationButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:navigationButton];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetNavigationButton];
}

// ----------------------------------------------------------------------------

- (void) resetNavigationButton {
    if (gAppDelegate.rootController.controllerStack.count > 1) {
        navigationButton.image = [UIImage imageNamed:@"Back-Button"];
    } else {
        navigationButton.image = [UIImage imageNamed:@"Menu-Button"];
    }   
}

// ----------------------------------------------------------------------------

- (void) navigationButtonTapped:(id)sender {
    if (gAppDelegate.rootController.controllerStack.count > 1) {
        [gAppDelegate.rootController popViewControllerAnimated:YES];
    } else if (gAppDelegate.rootController.menuIsVisible) {
        [gAppDelegate.rootController hideMenu];
    } else {
        [gAppDelegate.rootController showMenu];
    }
}

// ----------------------------------------------------------------------------

@end
