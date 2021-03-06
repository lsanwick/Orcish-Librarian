//
//  BasicSearchController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/6/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "BasicSearchController.h"
#import "CardViewController.h"
#import "CardSequence.h"
#import "AppDelegate.h"
#import "PriceManager.h"
#import "Card.h"
#import "SearchResultCell.h"

#define kPriceRequestDelay 1.5


@interface BasicSearchController ()

@property (assign, nonatomic) BOOL hasBeenFirstResponder;

@end

@implementation BasicSearchController

@synthesize searchBar;
@synthesize hasBeenFirstResponder;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.shouldDisplayPricesInResults = YES;
    self.hasBeenFirstResponder = NO;
}

// ----------------------------------------------------------------------------

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
//  UISearchBarDelegate
// ----------------------------------------------------------------------------

- (void) searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CardSequence *sequence = [Card findCardsByTitleText:searchText];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([bar.text isEqualToString:searchText]) {
                self.sequence = sequence;
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (gAppDelegate.rootController.topController == self) {            
        [gAppDelegate showCards:self.sequence atPosition:indexPath.row];         
    }
}
    
// ----------------------------------------------------------------------------
    
@end
