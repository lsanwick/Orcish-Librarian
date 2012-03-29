//
//  BasicSearchController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/6/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "BasicSearchController.h"
#import "OrcishViewController.h"
#import "CardViewController.h"
#import "AppDelegate.h"
#import "Card.h"

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
    if (!self.hasBeenFirstResponder) {
        self.hasBeenFirstResponder = YES;
        [self.searchBar becomeFirstResponder];
    }
}

// ----------------------------------------------------------------------------

- (void) setResults:(NSArray *)cards {
    BOOL collapseResults = YES; // TODO: drive this value with settings
    if (collapseResults) {
        results = [self collapsedResults:cards];                
    } else {
        results = [cards copy];
    }    
    [self.resultsTable reloadData];
}

// ----------------------------------------------------------------------------

- (NSArray *) collapsedResults:(NSArray *)cards {
    NSMutableArray *collapsedResults = [NSMutableArray arrayWithCapacity:cards.count];
    NSMutableDictionary *names = [NSMutableDictionary dictionaryWithCapacity:cards.count];
    for (Card *card in cards) {
        if ([names objectForKey:card.name] == nil) {
            [collapsedResults addObject:card];
            [names setObject:card forKey:card.name];
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
    static NSString *kCellIdentifier = @"SearchCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];        
    }
    Card *card = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", card.name, card.versionCount];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [gAppDelegate hideMenu];
    [gAppDelegate hideKeyboard];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (gAppDelegate.rootController.topController == self) {
        CardViewController *controller = [gAppDelegate.rootController dequeueCardViewController];
        controller.cards = results;
        controller.position = indexPath.row;
        [gAppDelegate.rootController pushViewController:controller animated:YES];
    }
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
