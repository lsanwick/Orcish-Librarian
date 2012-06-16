//
//  AdvancedSearchController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/3/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "OrcishViewController.h"


@interface AdvancedSearchController : OrcishViewController

- (IBAction) addButtonTapped:(id)sender;
- (IBAction) resetButtonTapped:(id)sender;
- (IBAction) searchButtonTapped:(id)sender;

@property (nonatomic, strong) IBOutlet UIView *emptyScreen;

@end
