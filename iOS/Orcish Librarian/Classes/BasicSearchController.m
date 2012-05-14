//
//  BasicSearchController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/6/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "BasicSearchController.h"
#import "CardViewController.h"
#import "AppDelegate.h"
#import "PriceManager.h"
#import "Card.h"
#import "SearchResultCell.h"

#define kPriceRequestDelay  1.5


@interface BasicSearchController ()

@property (assign, nonatomic) BOOL hasBeenFirstResponder;
@property (copy, nonatomic) NSArray *results;

@end

@implementation BasicSearchController

@synthesize resultsTable;
@synthesize searchBar;
@synthesize results;
@synthesize hasBeenFirstResponder;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.hasBeenFirstResponder = NO;
    self.results = [NSArray array];
    self.resultsTable.backgroundColor = self.resultsTable.separatorColor = 
        [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
}

// ----------------------------------------------------------------------------

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.resultsTable.scrollsToTop = NO;
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.resultsTable.scrollsToTop = YES;
}

// ----------------------------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
    [gAppDelegate trackScreen:@"/BasicSearch"];
    if (!self.hasBeenFirstResponder) {
        self.hasBeenFirstResponder = YES;
        [self.searchBar becomeFirstResponder];
    }
}

// ----------------------------------------------------------------------------

- (void) setResults:(NSArray *)cards {
    results = cards;
    [self.resultsTable reloadData];
    [[PriceManager shared] clearPriceRequests];
    NSArray *currentResults = results;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kPriceRequestDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (results == currentResults && results.count > 0) {
            [[PriceManager shared] clearPriceRequests];
            for (Card *card in cards.reverseObjectEnumerator) {
                [[PriceManager shared] requestPriceForCard:card withCallback:^(Card *card, NSDictionary *prices){
                    [resultsTable reloadData];
                }];         
            }
        }
    });
}

// ----------------------------------------------------------------------------
//  UIScrollViewDelegate
// ----------------------------------------------------------------------------

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [gAppDelegate hideKeyboard];
    [gAppDelegate hideMenu];
}

// ----------------------------------------------------------------------------
//  UISearchBarDelegate
// ----------------------------------------------------------------------------

- (void) searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText {
    dispatch_async(gAppDelegate.dbQueue, ^{
        NSArray *cards = [Card collapseCardList:[Card findCardsByTitleText:searchText]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([bar.text isEqualToString:searchText]) {
                self.results = cards;
            }
        });
    });
}

// ----------------------------------------------------------------------------

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [gAppDelegate hideKeyboard];
}

// ----------------------------------------------------------------------------

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [gAppDelegate hideMenu];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate
// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CardCell";
    SearchResultCell *cell = (SearchResultCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell =  [[SearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } 
    cell.card = (indexPath.row < self.results.count) ? [self.results objectAtIndex:indexPath.row] : nil;
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.results.count) {
        [gAppDelegate trackEvent:@"Search Results" action:@"Click" label:[[results objectAtIndex:indexPath.row] displayName]];
        [gAppDelegate hideMenu];
        [gAppDelegate hideKeyboard];        
        if (gAppDelegate.rootController.topController == self) {
            [gAppDelegate showCards:results atPosition:indexPath.row];
        }
    }
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = (indexPath.row % 2) ?
        tableView.separatorColor :    
        [UIColor whiteColor];
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:indexPath {
    return [SearchResultCell height];
}

// ----------------------------------------------------------------------------
//  UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {    
    return 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(6, self.results.count);
}

// ----------------------------------------------------------------------------

@end
