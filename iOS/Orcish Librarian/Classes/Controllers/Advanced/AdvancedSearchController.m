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
    self.facetNames = [NSArray arrayWithObjects:
        @"Card Text",
        @"Colors",
        @"Type",
        @"Set",
        @"Format",
        @"Rarity",
        @"Converted Mana Cost",
        @"Power",
        @"Toughness",
        @"Name",
        nil];
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

// ----------------------------------------------------------------------------

- (void) addFacet:(SearchFacet *)facet {
    [self.facets addObject:facet];
    [self.tableView reloadData];
}

// ----------------------------------------------------------------------------

- (IBAction) resetButtonTapped:(id)sender {
    [self.facets removeAllObjects];
    [self.tableView reloadData];
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
    return (self.facets.count > 0 ? 2 : 1);
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.facets.count > 0) {
        return self.facets.count;
    } else {
        return self.facetNames.count;
    }
}

// ----------------------------------------------------------------------------

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.facets.count > 0 && section == 0) {
        return @"Current Criteria";
    } else {
        return @"Add Criteria";
    }
}

// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *facetNameIdentifier = @"FacetNameCell";
    static NSString *facetIdentifier = @"FacetCell";
    if (self.facets.count > 0 && indexPath.section == 0) {
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:facetIdentifier];    
        if (cell == nil) {
            cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:facetIdentifier];
        }         
        SearchFacet *facet = [self.facets objectAtIndex:indexPath.row];
        cell.textLabel.text = facet.description;
        return cell;
    } else {        
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:facetNameIdentifier];    
        if (cell == nil) {
            cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:facetNameIdentifier];
        }         
        cell.textLabel.text = [self.facetNames objectAtIndex:indexPath.row];
        return cell;
    }    
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.facets.count > 0 && indexPath.section == 0) {
        NSLog(@"Selected a facet. NOT ALLOWED YET");
    } else {
        NSString *facet = [self.facetNames objectAtIndex:indexPath.row];
        if ([facet isEqualToString:@"Card Text"]) {
            FacetOptionController *controller = [[FacetOptionOracleTextController alloc] init];
            [controller view];
            controller.searchController = self;
            controller.title = facet;
            [gAppDelegate.rootController pushViewController:controller animated:YES];
        }
    }    
}

// ----------------------------------------------------------------------------

@end
