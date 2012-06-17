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
@property (nonatomic, strong) NSArray *facetNames;

@end

@implementation AdvancedSearchController

@synthesize criteria;
@synthesize facetNames;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.facetNames = [NSArray arrayWithObjects:
        @"Name",
        @"Oracle Text",
        @"Type",
        @"Rarity",
        @"Set",
        @"Block",
        @"Format",
        @"Colors",
        @"Power",
        @"Toughness",
        @"Converted Mana Cost",
        nil];
}

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
//  UITableViewDelegate and UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return self.facetNames.count;
}

// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SearchCriteriaTypeCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];    
    if (cell == nil) {
        cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }         
    cell.textLabel.text = [self.facetNames objectAtIndex:indexPath.row];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSString *facetName = [[self.facetNames objectAtIndex:indexPath.row] uppercaseString];    
}

// ----------------------------------------------------------------------------

@end
