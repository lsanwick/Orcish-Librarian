//
//  ExternalSiteController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 8/15/10.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishViewController.h"

@interface ExternalSiteController : OrcishViewController <UIActionSheetDelegate, UIWebViewDelegate> 

- (void) updateBrowserButtons;
- (IBAction) doneButtonClicked:(id)sender;
- (IBAction) backButtonClicked:(id)sender;
- (IBAction) forwardButtonClicked:(id)sender;
- (IBAction) safariButtonClicked:(id)sender;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIActionSheet *activeActionSheet;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *safariButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
