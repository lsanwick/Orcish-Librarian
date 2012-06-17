//
//  AboutController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/20/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "AboutController.h"
#import "AppDelegate.h"
#import "DataManager.h"

@interface AboutController ()

@end

@implementation AboutController

@synthesize webView;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.webView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Linen-Background"]];
    NSURL *aboutURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HTML/About.html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:aboutURL]];
}

// ----------------------------------------------------------------------------
//  UIWebViewDelegate
// ----------------------------------------------------------------------------

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = request.URL;    
    
    // DONE LOADING WEBVIEW
    if ([URL.scheme isEqualToString:@"orcish"]) {
        [gAppDelegate trackEvent:@"About Screen" action:@"Launch Orcish Homepage" label:@""];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://orcish.info"]];
    } 
    
    else {
        return YES;
    }
    
    return NO;
}

// ----------------------------------------------------------------------------

- (void) webViewDidFinishLoad:(UIWebView *)webView {    
    NSString *setVersion = [NSString stringWithFormat:@"About.setVersion('v.%@');", 
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [self.webView stringByEvaluatingJavaScriptFromString:setVersion];
    if (gDataManager.lastUpdated) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateStyle = NSDateFormatterMediumStyle;
        NSString *formattedDate = [format stringFromDate:gDataManager.lastUpdated];
        NSString *lastUpdateText = [NSString stringWithFormat:@"Last checked on %@", formattedDate];
        NSString *setLastUpdate = [NSString stringWithFormat:@"About.setLastUpdate('%@');",
            [lastUpdateText stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]];
        [self.webView stringByEvaluatingJavaScriptFromString:setLastUpdate];
    }
}

// ----------------------------------------------------------------------------

@end
