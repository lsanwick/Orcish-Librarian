//
//  AdvancedSearchController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/3/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "AdvancedSearchController.h"
#import "FacetSelectionController.h"
#import "AppDelegate.h"

@interface AdvancedSearchController ()

@property (nonatomic, strong) NSMutableArray *criteria;

@end

@implementation AdvancedSearchController

@synthesize criteria;

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

// ----------------------------------------------------------------------------

- (IBAction) resetButtonTapped:(id)sender {
    NSLog(@"Reset");    
}

// ----------------------------------------------------------------------------

- (IBAction) searchButtonTapped:(id)sender {
    NSLog(@"Search");
}

// ----------------------------------------------------------------------------

@end
