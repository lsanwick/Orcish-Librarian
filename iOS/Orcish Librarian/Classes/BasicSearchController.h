//
//  BasicSearchController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/6/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrcishViewController.h"

@class CardViewController;

@interface BasicSearchController : OrcishViewController <UITableViewDelegate, UITableViewDataSource> 

@property (strong, nonatomic) IBOutlet UITableView *resultsTable;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet CardViewController *cardViewController;
@property (copy, nonatomic) NSArray *results;
@property (assign, nonatomic) BOOL hasBeenFirstResponder;

- (NSArray *) collapsedResults:(NSArray *)cards;

@end
