//
//  PriceListController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/29/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishViewController.h"

@interface PriceListController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UIView *timeoutView;
@property (nonatomic, strong) IBOutlet UIButton *retryButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *foilButton;

- (IBAction) doneButtonTapped:(id)sender;
- (IBAction) retryButtonTapped:(id)sender;

@property (nonatomic, strong) NSString *productId;

@end
