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
    [self view];
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
    BOOL collapseResults = YES; // TODO: pull from preferences
    results = collapseResults ? [self collapsedResults:cards] : [cards copy];
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

- (NSArray *) collapsedResults:(NSArray *)cards {
    NSMutableArray *collapsedResults = [NSMutableArray arrayWithCapacity:cards.count];
    NSMutableDictionary *names = [NSMutableDictionary dictionaryWithCapacity:cards.count];
    for (Card *card in cards) {
        if ([names objectForKey:card.displayName] == nil) {
            [collapsedResults addObject:card];
            [names setObject:card forKey:card.displayName];
        }
    }
    return collapsedResults;
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
        NSArray *cards = [Card findCardsByTitleText:searchText];
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
    } 
    cell.card = [self.results objectAtIndex:indexPath.row];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [gAppDelegate trackEvent:@"Search Results" action:@"Click" label:[[results objectAtIndex:indexPath.row] displayName]];
    [gAppDelegate hideMenu];
    [gAppDelegate hideKeyboard];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (gAppDelegate.rootController.topController == self) {
        [gAppDelegate showCards:results atPosition:indexPath.row];
    }
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
    return self.results.count;
}

// ----------------------------------------------------------------------------

@end
