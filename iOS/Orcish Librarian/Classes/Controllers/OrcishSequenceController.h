//
//  OrcishSequenceController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/11/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishViewController.h"

@class OrcishRootController;
@class CardSequence;

@interface OrcishSequenceController : OrcishViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

- (void) setSequence:(CardSequence *)sequence reloadTable:(BOOL)reloadTable;

@property (nonatomic, assign) BOOL shouldDisplayPricesInResults;
@property (nonatomic, strong) CardSequence *sequence;
@property (nonatomic, strong) IBOutlet UITableView *cardListView;

@end
