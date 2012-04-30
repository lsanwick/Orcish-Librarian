//
//  PriceListController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/29/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "PriceListController.h"
#import "AppDelegate.h"


@interface PriceListController ()

@end


@implementation PriceListController

// ----------------------------------------------------------------------------

- (void) viewDidLoad {

}

// ----------------------------------------------------------------------------

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ----------------------------------------------------------------------------

- (IBAction) doneButtonTapped:(id)sender {
    [gAppDelegate.rootController dismissModalViewControllerAnimated:YES];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

// ----------------------------------------------------------------------------

@end
