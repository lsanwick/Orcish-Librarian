//
//  OrcishViewController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/11/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrcishRootController;

@interface OrcishViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *cardList;
@property (nonatomic, strong) IBOutlet UITableView *cardListView;
@property (nonatomic, strong) IBOutlet UINavigationItem *navigationItem;

@end
