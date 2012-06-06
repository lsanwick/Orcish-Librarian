//
//  AdvancedSearchController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/3/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "AdvancedSearchController.h"

@interface AdvancedSearchController ()

@property (nonatomic, strong) NSMutableArray *criteria;

@end

@implementation AdvancedSearchController

@synthesize emptyScreen;
@synthesize criteria;

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.emptyScreen.hidden = (self.criteria.count > 0);
}

// ----------------------------------------------------------------------------

- (IBAction) addButtonTapped:(id)sender {
    NSLog(@"Add");
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
