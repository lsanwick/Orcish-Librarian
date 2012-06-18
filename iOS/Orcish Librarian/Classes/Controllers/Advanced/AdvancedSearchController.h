//
//  AdvancedSearchController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/3/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "OrcishViewController.h"


@class SearchFacet;    

@interface AdvancedSearchController : OrcishViewController <UITableViewDataSource, UITableViewDelegate>

- (void) addFacet:(SearchFacet *)facet;

- (IBAction) resetButtonTapped:(id)sender;
- (IBAction) searchButtonTapped:(id)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
