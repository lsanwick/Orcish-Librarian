//
//  PriceListController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/29/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PriceListController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;

- (IBAction) doneButtonTapped:(id)sender;

@property (nonatomic, strong) NSString *productId;

@end
