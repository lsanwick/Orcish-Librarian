//
//  OrcishSequenceController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/11/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "OrcishSequenceController.h"
#import "OrcishRootController.h"
#import "SearchResultCell.h"
#import "AppDelegate.h"
#import "PriceManager.h"
#import "Card.h"
#import "CardSequence.h"

#define kPriceRequestDelay  1.5


@implementation OrcishSequenceController

@synthesize shouldDisplayPricesInResults;
@synthesize sequence;
@synthesize cardListView;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.cardListView.rowHeight = [SearchResultCell height];
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cardListView deselectRowAtIndexPath:[self.cardListView indexPathForSelectedRow] animated:animated];
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
        if (self.shouldDisplayPricesInResults) {
            [[PriceManager shared] clearPriceRequests];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kPriceRequestDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (self.sequence == theSequence && theSequence.count > 0) {
                    for (int i = theSequence.count - 1; i >= 0; i--) {
                        Card *card = [theSequence cardAtPosition:i];
                        [[PriceManager shared] requestPriceForCard:card withCallback:^(Card *card, NSDictionary *prices){
                            [self.cardListView reloadData];
                        }];         
                    }
                }
            });
        }
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
