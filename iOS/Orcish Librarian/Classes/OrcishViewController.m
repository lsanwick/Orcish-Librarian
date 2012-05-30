//
//  OrcishViewController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/11/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "OrcishViewController.h"
#import "OrcishRootController.h"
#import "SearchResultCell.h"
#import "AppDelegate.h"
#import "PriceManager.h"
#import "Card.h"
#import "CardSequence.h"

#define kPriceRequestDelay  1.5


@interface OrcishViewController () {
    UIBarButtonItem *navigationButton;
}
    
@end


@implementation OrcishViewController

@dynamic navigationItem;
@synthesize shouldDisplayPricesInResults;
@synthesize parentViewController;
@synthesize sequence;
@synthesize cardListView;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.cardListView.rowHeight = [SearchResultCell height];
    navigationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu-Button"] 
        style:UIBarButtonItemStyleBordered target:self action:@selector(navigationButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:navigationButton];
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cardListView deselectRowAtIndexPath:[self.cardListView indexPathForSelectedRow] animated:animated];
    [self resetNavigationButton];
}

// ----------------------------------------------------------------------------

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

// ----------------------------------------------------------------------------

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

// ----------------------------------------------------------------------------

- (void) resetNavigationButton {
    if (gAppDelegate.rootController.controllerStack.count > 1) {
        navigationButton.image = [UIImage imageNamed:@"Back-Button"];
    } else {
        navigationButton.image = [UIImage imageNamed:@"Menu-Button"];
    }   
}

// ----------------------------------------------------------------------------

- (void) navigationButtonTapped:(id)sender {
    if (gAppDelegate.rootController.controllerStack.count > 1) {
        [gAppDelegate.rootController popViewControllerAnimated:YES];
    } else if (gAppDelegate.rootController.menuIsVisible) {
        [gAppDelegate.rootController hideMenu];
    } else {
        [gAppDelegate.rootController showMenu];
    }
}

// ----------------------------------------------------------------------------

+ (NSArray *) collapsedResults:(NSArray *)cards {
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

- (void) setSequence:(CardSequence *)theSequence reloadTable:(BOOL)reloadTable {
    sequence = theSequence;
    if (reloadTable) {
        [self.cardListView reloadData];
    }
}

// ----------------------------------------------------------------------------

- (void) setSequence:(CardSequence *)theSequence {
    [self setSequence:theSequence reloadTable:YES];
}

// ----------------------------------------------------------------------------
//  UIScrollViewDelegate
// ----------------------------------------------------------------------------

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [gAppDelegate hideKeyboard];
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
        cell.shouldDisplayPricesInResults = self.shouldDisplayPricesInResults;
    }     
    cell.card = [self.sequence cardAtPosition:indexPath.row];
    return cell;
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:indexPath {
    return [SearchResultCell height];
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    [gAppDelegate showCards:self.sequence atPosition:indexPath.row];
}

// ----------------------------------------------------------------------------
//  UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {    
    return 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sequence.count;
}

// ----------------------------------------------------------------------------

@end
