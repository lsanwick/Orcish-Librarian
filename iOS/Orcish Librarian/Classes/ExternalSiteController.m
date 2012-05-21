//
//  ExternalSiteController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 8/15/10.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "ExternalSiteController.h"
#import "AppDelegate.h"

@implementation ExternalSiteController

@synthesize webView;
@synthesize doneButton;
@synthesize backButton;
@synthesize forwardButton;
@synthesize safariButton;
@synthesize activityIndicator;
@synthesize activeActionSheet;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
}

// ----------------------------------------------------------------------------

- (void) updateBrowserButtons {
    self.forwardButton.enabled = self.webView.canGoForward;
    self.self.backButton.enabled = self.webView.canGoBack;
    safariButton.enabled = ![self.webView.request.URL.absoluteString isEqualToString:@""];    
}

// ----------------------------------------------------------------------------

- (NSURL *) URL {
    return [[self.webView request] URL];
}

// ----------------------------------------------------------------------------

- (void) setURL:(NSURL *)URL {
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

// ----------------------------------------------------------------------------

- (IBAction) doneButtonClicked:(id)sender {
    [self.activeActionSheet dismissWithClickedButtonIndex:1 animated:YES];
    [gAppDelegate.rootController dismissModalViewControllerAnimated:YES];
}

// ----------------------------------------------------------------------------

- (IBAction) backButtonClicked:(id)sender {
    [self.activeActionSheet dismissWithClickedButtonIndex:1 animated:YES];
    [self.webView goBack];
}

// ----------------------------------------------------------------------------

- (IBAction) forwardButtonClicked:(id)sender {
    [self.activeActionSheet dismissWithClickedButtonIndex:1 animated:YES];
    [self.webView goForward];
}

// ----------------------------------------------------------------------------

- (IBAction) safariButtonClicked:(id)sender {
    if(self.activeActionSheet == nil) {
        self.activeActionSheet = [[UIActionSheet alloc] init];
        [self.activeActionSheet setDelegate:self];
        [self.activeActionSheet addButtonWithTitle:@"Open in Safari"];
        [self.activeActionSheet addButtonWithTitle:@"Cancel"];
        [self.activeActionSheet setCancelButtonIndex:1];
        [self.activeActionSheet showInView:self.view];
    }
    else {
        [self.activeActionSheet dismissWithClickedButtonIndex:1 animated:YES]; 
    }
}

// ----------------------------------------------------------------------------
//  UIActionSheetDelegate
// ----------------------------------------------------------------------------

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.activeActionSheet = nil;
    if(buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:webView.request.URL];
    }
}

// ----------------------------------------------------------------------------
//  UIAlertViewDelegate
// ----------------------------------------------------------------------------

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(self.webView.request.URL == nil || [self.webView.request.URL.absoluteString isEqualToString:@""]) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

// ----------------------------------------------------------------------------
//  UIWebViewDelegate
// ----------------------------------------------------------------------------

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

// ----------------------------------------------------------------------------

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
    [self updateBrowserButtons];
}

// ----------------------------------------------------------------------------

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self updateBrowserButtons];
}

// ----------------------------------------------------------------------------

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"Cannot Open Page"];
    [alert setMessage:@"This application could not open the requested page."];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    [self.activityIndicator stopAnimating];
    [self updateBrowserButtons];
}

// ----------------------------------------------------------------------------

@end
