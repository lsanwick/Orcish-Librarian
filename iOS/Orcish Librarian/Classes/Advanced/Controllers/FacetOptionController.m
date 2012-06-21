//
//  FacetOptionController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/16/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "FacetOptionController.h"
#import "AppDelegate.h"
#import "AdvancedSearchController.h"
#import "SearchFacet.h"

@interface FacetOptionController ()

- (SearchFacet *) createFacet;

@end

@implementation FacetOptionController

@synthesize searchController;

// ----------------------------------------------------------------------------

- (id) init {
    return [super initWithNibName:@"FacetOptionController" bundle:nil];
}

// ----------------------------------------------------------------------------

- (void) setTitle:(NSString *)title {
    self.navigationItem.title = title;
}

// ----------------------------------------------------------------------------

- (IBAction) doneButtonTapped:(id)sender {
    [self.searchController addFacet:[self createFacet]];
    [gAppDelegate.rootController popViewControllerAnimated:YES];
}

// ----------------------------------------------------------------------------

- (SearchFacet *) createFacet {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
        userInfo:nil];
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
    static NSString *identifier = @"FacetOptionCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];    
    if (cell == nil) {
        cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }         
    return cell;
}

// ----------------------------------------------------------------------------

@end
