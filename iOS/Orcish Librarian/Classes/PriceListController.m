//
//  PriceListController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/29/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "PriceListController.h"
#import "AppDelegate.h"
#import "PriceVendorCell.h"


@interface PriceListController ()

@property (nonatomic, strong) NSArray *prices;
@property (nonatomic, assign) BOOL firstRequestMade;

@end


@implementation PriceListController

@synthesize webView;
@synthesize tableView;
@synthesize loadingView;
@synthesize productId;
@synthesize prices;
@synthesize firstRequestMade;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    self.webView.delegate = self;
}

// ----------------------------------------------------------------------------

- (void) setProductId:(NSString *)theProductId {
    productId = theProductId;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:
        [NSString stringWithFormat:@"http://store.tcgplayer.com/product.aspx?id=%@", productId]]]];
}

// ----------------------------------------------------------------------------

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ----------------------------------------------------------------------------

- (void) setPrices:(NSArray *)thePrices {
    prices = thePrices;
    if (prices) {
        [self.tableView reloadData];
        self.loadingView.hidden = YES;
    } else {
        // TODO: log this error (analytics, please)
    }
}

// ----------------------------------------------------------------------------

- (IBAction) doneButtonTapped:(id)sender {
    [gAppDelegate.rootController dismissModalViewControllerAnimated:YES];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return self.prices.count;
}

// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PriceVendorCell";
    PriceVendorCell *cell = (PriceVendorCell *) [aTableView dequeueReusableCellWithIdentifier:identifier];    
    if (cell == nil) {
        cell =  [[PriceVendorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    } 
    cell.vendor = [self.prices objectAtIndex:indexPath.row];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
        [NSString stringWithFormat:@"http://store.tcgplayer.com/product.aspx?id=%@", productId]]];
    [gAppDelegate.rootController dismissModalViewControllerAnimated:YES];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate
// ----------------------------------------------------------------------------

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = request.URL;
    if ([URL.scheme isEqualToString:@"done"]) {
        NSString *pricesAsJSON = [self.webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(window._orcish_librarian_prices)"];
        if (pricesAsJSON) {
            NSError *error = nil;
            self.prices = [NSJSONSerialization JSONObjectWithData:[pricesAsJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        } else {
            // TODO: log this error (analytics, please)
        }
        return NO;
    } else if (self.firstRequestMade) {
        return NO;
    } else {
        self.firstRequestMade = YES;
        return YES;
    }
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:indexPath {
    return [PriceVendorCell height];
}

// ----------------------------------------------------------------------------
//  UIWebViewDelegate
// ----------------------------------------------------------------------------

- (void) webViewDidFinishLoad:(UIWebView *)theWebView {
    [self.webView stringByEvaluatingJavaScriptFromString:@"(function(){ var s = document.createElement('script'); s.src = 'http://orcish.info/librarian/prices.js'; document.getElementsByTagName('head')[0].appendChild(s); })()"];
}

// ----------------------------------------------------------------------------

@end
