//
//  BasicSearchController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/6/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CardViewController;

@interface BasicSearchController : UIViewController <UITableViewDelegate, UITableViewDataSource> 

@property (strong, nonatomic) IBOutlet UITableView *resultsTable;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
