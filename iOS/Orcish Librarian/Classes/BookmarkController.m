//
//  BookmarkController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/7/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "BookmarkController.h"
#import "CardViewController.h"
#import "AppDelegate.h"
#import "PriceManager.h"
#import "Card.h"
#import "SearchResultCell.h"

#define kPriceRequestDelay  1.5


@interface BookmarkController ()

- (void) reloadCards;
- (NSArray *) collapsedResults:(NSArray *)theCards;

@property (nonatomic, strong) NSArray *cards;

@end


@implementation BookmarkController

@synthesize resultsTable;
@synthesize cards;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    [self view];
}

// ----------------------------------------------------------------------------

- (void) loadView {
    self.resultsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.resultsTable.delegate = self;
    self.resultsTable.dataSource = self;
    self.view = self.resultsTable;    
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadCards];
}

// ----------------------------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [gAppDelegate trackScreen:@"/Bookmarks"];
}

// ----------------------------------------------------------------------------

- (void) reloadCards {
    self.cards = [[self collapsedResults:[Card findBookmarkedCards]] sortedArrayUsingDescriptors:
        [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES]]];
    [self.resultsTable reloadData];
}

// ----------------------------------------------------------------------------

- (NSArray *) collapsedResults:(NSArray *)theCards {
    NSMutableArray *collapsedResults = [NSMutableArray arrayWithCapacity:theCards.count];
    NSMutableDictionary *names = [NSMutableDictionary dictionaryWithCapacity:theCards.count];
    for (Card *card in theCards) {
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
    cell.card = [self.cards objectAtIndex:indexPath.row];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Card *card = [self.cards objectAtIndex:indexPath.row];
    [gAppDelegate trackEvent:@"Bookmarks" action:@"Show Card" label:card.displayName];
    [gAppDelegate showCard:card];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
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
    return self.cards.count;
}

// ----------------------------------------------------------------------------

@end
