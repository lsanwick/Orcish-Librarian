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
@property (nonatomic, strong) NSArray *foilPrices;
@property (nonatomic, assign) BOOL firstRequestMade;
@property (nonatomic, assign) BOOL showFoilsOnly;
@property (nonatomic, readonly) NSArray *currentPrices;

@end


@implementation PriceListController

@synthesize webView;
@synthesize tableView;
@synthesize loadingView;
@synthesize foilButton;
@synthesize productId;
@synthesize prices;
@synthesize foilPrices;
@synthesize showFoilsOnly;
@synthesize firstRequestMade;

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [gAppDelegate trackScreen:@"/CardView/Prices"];
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
        NSIndexSet *foilIndexes = [prices indexesOfObjectsPassingTest:^(id price, NSUInteger i, BOOL *s) { return (BOOL) (([[price objectForKey:@"condition"] rangeOfString:@"foil" options:NSCaseInsensitiveSearch]).location != NSNotFound); }];
        self.foilPrices = [prices objectsAtIndexes:foilIndexes];
        self.foilButton.enabled = (self.foilPrices.count > 0);
    } else {
        [gAppDelegate trackEvent:@"All Prices" action:@"Failed" label:@"Nil prices"];
    }
}

// ----------------------------------------------------------------------------

- (NSArray *) currentPrices {
    return self.showFoilsOnly ? self.foilPrices : self.prices;
}
    
// ----------------------------------------------------------------------------

- (IBAction) foilButtonTapped:(id)sender {
    if (self.showFoilsOnly) {
        [gAppDelegate trackEvent:@"All Prices" action:@"Show All" label:@""];
        [self.foilButton setTitle:@"Foils"];
    } else {
        [gAppDelegate trackEvent:@"All Prices" action:@"Show Foils" label:@""];
        [self.foilButton setTitle:@"Any"];
    }
    self.showFoilsOnly = !self.showFoilsOnly;
    [self.tableView reloadData];
}

// ----------------------------------------------------------------------------

- (IBAction) doneButtonTapped:(id)sender {
    [gAppDelegate trackEvent:@"All Prices" action:@"Done" label:@""];
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
    return self.currentPrices.count;
}

// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PriceVendorCell";
    PriceVendorCell *cell = (PriceVendorCell *) [aTableView dequeueReusableCellWithIdentifier:identifier];    
    if (cell == nil) {
        cell =  [[PriceVendorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }     
    cell.vendor = [self.currentPrices objectAtIndex:indexPath.row];
    return cell;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [gAppDelegate trackEvent:@"All Prices" action:@"Show TCGPlayer" label:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
        [NSString stringWithFormat:@"http://store.tcgplayer.com/product.aspx?id=%@&partner=ORCSHLBRN", productId]]];
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
            [gAppDelegate trackEvent:@"All Prices" action:@"Failed" label:@"Bad JSON"];
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
