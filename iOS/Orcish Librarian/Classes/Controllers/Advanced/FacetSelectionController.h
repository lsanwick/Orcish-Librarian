//
//  FacetSelectionController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/16/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishSequenceController.h"

@class AdvancedSearchController;

@interface FacetSelectionController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction) cancelTapped:(id)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AdvancedSearchController *searchController;

@end
