//
//  AdvancedSearchController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/3/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "AdvancedSearchController.h"
#import "FacetOptionTextController.h"
#import "AppDelegate.h"
#import "Card.h"
#import "Facet.h"

@interface AdvancedSearchController ()

@property (nonatomic, strong) NSMutableArray *facets;
@property (nonatomic, strong) NSArray *categories;

@end

@implementation AdvancedSearchController

@synthesize tableView;
@synthesize searchButton;
@synthesize resetButton;
@synthesize facets;
@synthesize categories;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.facets = [NSMutableArray array];
    self.categories = [NSArray arrayWithObjects:
        [FacetCategory titleText],
        nil];
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.searchButton.enabled = self.facets.count > 0;  
}

// ----------------------------------------------------------------------------

- (void) addFacet:(SearchFacet *)facet {
    [self.facets addObject:facet];
    [self.tableView reloadData];
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

- (FacetOptionController *) optionControllerForCategory:(FacetCategory *)category {
    switch (category.identifier) {
        case kFacetTitleText:
            return [[FacetOptionTextController alloc] init];
        default:
            return nil;
    }
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate and UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)aTableView {
    return (self.facets.count > 0) ? 2 : 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return (self.facets.count > 0 && section == 0) ?
        self.facets.count :
        self.categories.count;
}

// ----------------------------------------------------------------------------

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (self.facets.count > 0 && section == 0) ?
        @"Selected Criteria" :
        @"Add Criteria";
}

// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *facetCategoryId = @"FacetCategoryCell";
    static NSString *facetId = @"FacetCell";
    if (self.facets.count > 0 && indexPath.section == 0) {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:facetId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:facetId];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = [[self.facets objectAtIndex:indexPath.row] description];
        cell.detailTextLabel.text = [[[self.facets objectAtIndex:indexPath.row] category] description];
        return cell;
    } else {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:facetCategoryId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:facetCategoryId];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = [[self.categories objectAtIndex:indexPath.row] description];
        return cell;
    }    
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

// ----------------------------------------------------------------------------

@end
