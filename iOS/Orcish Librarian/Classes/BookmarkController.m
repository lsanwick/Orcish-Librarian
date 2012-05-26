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

@end


@implementation BookmarkController

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Bookmarks";
    self.shouldCollapseResults = NO;
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadCards];
    [self.cardListView reloadData];
}

// ----------------------------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

// ----------------------------------------------------------------------------

- (void) reloadCards {
    self.cardList = [Card findBookmarkedCards]; // [[Card findBookmarkedCards] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES]]];
}

// ----------------------------------------------------------------------------
//  UITableViewDataSource
// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {    
        Card *card = [self.cardList objectAtIndex:indexPath.row];
        [card setIsBookmarked:NO];
        [self setCardList:[Card findBookmarkedCards] reloadTable:NO];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }  
}

// ----------------------------------------------------------------------------

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// ----------------------------------------------------------------------------

@end
