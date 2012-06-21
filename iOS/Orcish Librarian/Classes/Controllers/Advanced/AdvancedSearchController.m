//
//  AdvancedSearchController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/3/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "AdvancedSearchController.h"
#import "FacetOptionOracleTextController.h"
#import "AppDelegate.h"
#import "Card.h"
#import "SearchFacet.h"

@interface AdvancedSearchController ()

@property (nonatomic, strong) NSMutableArray *facets;
@property (nonatomic, strong) NSArray *facetNames;

@end

@implementation AdvancedSearchController

@synthesize tableView;
@synthesize facets;
@synthesize facetNames;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.facets = [NSMutableArray array];
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

// ----------------------------------------------------------------------------

- (void) addFacet:(SearchFacet *)facet {

}

// ----------------------------------------------------------------------------

- (IBAction) resetButtonTapped:(id)sender {
    if (self.facets.count > 0) {
        [self.tableView beginUpdates];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
            [self.facets removeAllObjects];
        [self.tableView endUpdates];
    }        
}

// ----------------------------------------------------------------------------

- (IBAction) searchButtonTapped:(id)sender {
    CardSequence *results = [Card findCards:self.facets];
    [gAppDelegate showCardList:results withTitle:@"Search Results"];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate and UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

// ----------------------------------------------------------------------------

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.facets.count > 0 && indexPath.section == 0) {
        return 56.0;
    } else {
        return 44.0;
    }
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

// ----------------------------------------------------------------------------

@end
