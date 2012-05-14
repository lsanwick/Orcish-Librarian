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
    self.resultsTable.backgroundColor = self.resultsTable.separatorColor = 
        [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
}

// ----------------------------------------------------------------------------

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.resultsTable.scrollsToTop = NO;
}

// ----------------------------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.resultsTable.scrollsToTop = YES;
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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    } 
    cell.textLabel.text = [[self.sets objectAtIndex:indexPath.row] name];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    CardSet *set = [self.sets objectAtIndex:indexPath.row];
    [gAppDelegate trackEvent:@"Browse" action:@"Show Set" label:set.name];
    [gAppDelegate showCardList:set.cards withTitle:set.name];
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = (indexPath.row % 2) ?
        tableView.separatorColor :    
        [UIColor whiteColor];
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:indexPath {
    return 44.0;
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
