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
    self.cardList = [[Card findBookmarkedCards] sortedArrayUsingDescriptors:[NSArray arrayWithObject:
        [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES]]];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate
// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.cardList.count) {
        [gAppDelegate showCards:self.cardList atPosition:indexPath.row];
    }
}

// ----------------------------------------------------------------------------
//  UITableViewDataSource
// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.cardList objectAtIndex:indexPath.row] setIsBookmarked:NO];
        [self reloadCards];
    }  
}

// ----------------------------------------------------------------------------

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row < self.cardList.count);
}

// ----------------------------------------------------------------------------

@end
