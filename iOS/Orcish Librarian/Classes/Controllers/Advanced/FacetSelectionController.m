//
//  FacetSelectionController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/16/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "FacetSelectionController.h"
#import "FacetOptionsController.h"
#import "AppDelegate.h"

@interface FacetSelectionController ()

@property (nonatomic, strong) NSArray *facetNames;

@end

@implementation FacetSelectionController

@synthesize tableView;
@synthesize searchController;
@synthesize facetNames;

// ----------------------------------------------------------------------------

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
    return self;
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

// ----------------------------------------------------------------------------

- (IBAction) cancelTapped:(id)sender {
    [gAppDelegate.rootController dismissModalViewControllerAnimated:YES];
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
