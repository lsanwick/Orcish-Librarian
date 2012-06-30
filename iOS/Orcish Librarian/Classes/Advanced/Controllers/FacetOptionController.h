//
//  FacetOptionController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/16/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishViewController.h"


@class AdvancedSearchController;
@class SearchFacet;

@interface FacetOptionController : OrcishViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction) doneButtonTapped:(id)sender;

- (void) setTitle:(NSString *)title;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) AdvancedSearchController *searchController;
@property (nonatomic, strong) SearchFacet *facet;

@end
