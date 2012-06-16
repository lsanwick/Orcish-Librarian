//
//  AboutController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/20/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishViewController.h"

@interface AboutController : OrcishViewController <UIScrollViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end
