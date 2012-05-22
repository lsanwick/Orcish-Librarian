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

#define kPriceRequestDelay  1.5


@interface OrcishViewController () {
    UIBarButtonItem *navigationButton;
}
    
+ (NSArray *) collapsedResults:(NSArray *)cards;

@end


@implementation OrcishViewController

@dynamic navigationItem;
@synthesize parentViewController;
@synthesize cardList;
@synthesize cardListView;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    navigationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Menu-Button"] 
        style:UIBarButtonItemStyleBordered target:self action:@selector(navigationButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:navigationButton];
    self.cardListView.separatorColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];        
    self.cardListView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Linen-Background"]];
    
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cardListView deselectRowAtIndexPath:[self.cardListView indexPathForSelectedRow] animated:animated];
    if (gAppDelegate.rootController.controllerStack.count > 1) {
        navigationButton.image = [UIImage imageNamed:@"Back-Button"];
    } else {
        navigationButton.image = [UIImage imageNamed:@"Menu-Button"];
    }
}

// ----------------------------------------------------------------------------

- (void) navigationButtonTapped:(id)sender {
    if (gAppDelegate.rootController.controllerStack.count > 1) {
        [gAppDelegate trackEvent:@"Navigation" action:@"Back" label:@""];
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

- (void) setCardList:(NSArray *)cards {
    cards = [[self class] collapsedResults:cards];
    cardList = cards;
    [self.cardListView reloadData];
    [[PriceManager shared] clearPriceRequests];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kPriceRequestDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.cardList == cards && cards.count > 0) {
            for (Card *card in cards.reverseObjectEnumerator) {
                [[PriceManager shared] requestPriceForCard:card withCallback:^(Card *card, NSDictionary *prices){
                    [self.cardListView reloadData];
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
//  UITableViewDelegate
// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CardCell";
    SearchResultCell *cell = (SearchResultCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell =  [[SearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }     
    cell.selectionStyle = (indexPath.row < self.cardList.count) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    cell.card = (indexPath.row < self.cardList.count) ? [self.cardList objectAtIndex:indexPath.row] : nil;
    return cell;
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:indexPath {
    return [SearchResultCell height];
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = (indexPath.row % 2) ? tableView.separatorColor : [UIColor whiteColor];
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    [gAppDelegate showCards:self.cardList atPosition:indexPath.row];
}

// ----------------------------------------------------------------------------
//  UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {    
    return 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(7, self.cardList.count);
}

// ----------------------------------------------------------------------------

@end
