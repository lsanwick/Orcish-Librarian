//
//  SetListController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/8/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "SetListController.h"
#import "AppDelegate.h"
#import "CardSet.h"


@interface SetListController ()

- (void) loadData;

@property (strong, nonatomic) NSArray *sets;

@end


@implementation SetListController

@synthesize resultsTable;
@synthesize sets;

// ----------------------------------------------------------------------------

- (void) loadData {
    self.sets = [CardSet findAll];
}

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

// ----------------------------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [gAppDelegate trackScreen:@"/Browse"];
}

// ----------------------------------------------------------------------------
//  UIScrollViewDelegate
// ----------------------------------------------------------------------------

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [gAppDelegate hideMenu];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate
// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    } 
    cell.textLabel.text = [[self.sets objectAtIndex:indexPath.row] name];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CardSet *set = [self.sets objectAtIndex:indexPath.row];
    [gAppDelegate trackEvent:@"Browse" action:@"Show Set" label:set.name];
    [gAppDelegate showCards:set.cards atPosition:0];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
}

// ----------------------------------------------------------------------------
//  UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {    
    return 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sets.count;
}

// ----------------------------------------------------------------------------

@end
