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

@property (strong, nonatomic) NSArray *allSets;
@property (strong, nonatomic) NSArray *recentSets;

@end


@implementation SetListController

@synthesize allSets;
@synthesize recentSets;

// ----------------------------------------------------------------------------

- (void) loadData {
    self.allSets = [CardSet findAll];
    self.recentSets = [CardSet findStandardSets];
}

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    self.cardListView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Linen-Background"]];
}

// ----------------------------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    NSArray *sets = (indexPath.section == 0) ? recentSets : allSets;
    cell.textLabel.text = [[sets objectAtIndex:indexPath.row] name];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sets = (indexPath.section == 0) ? recentSets : allSets;
    CardSet *set = [sets objectAtIndex:indexPath.row];
    [gAppDelegate showCardList:set.cards withTitle:set.name];
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:indexPath {
    return 44.0;
}

// ----------------------------------------------------------------------------
//  UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {    
    return 2;
}

// ----------------------------------------------------------------------------

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ?
        @"Recent Sets" :
        @"All Sets";
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ?
        self.recentSets.count :
        self.allSets.count;
}

// ----------------------------------------------------------------------------

@end
