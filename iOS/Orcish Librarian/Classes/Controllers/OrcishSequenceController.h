//
//  OrcishViewController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/11/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrcishRootController;
@class CardSequence;

@interface OrcishViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

- (void) setSequence:(CardSequence *)sequence reloadTable:(BOOL)reloadTable;
- (void) resetNavigationButton;

@property (nonatomic, assign) BOOL shouldDisplayPricesInResults;
@property (nonatomic, strong) CardSequence *sequence;
@property (nonatomic, strong) IBOutlet UITableView *cardListView;
@property (nonatomic, strong) IBOutlet UINavigationItem *navigationItem;

@end
