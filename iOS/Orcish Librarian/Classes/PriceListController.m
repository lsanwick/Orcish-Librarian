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
#import "RegexKitLite.h"

#define kRequestTimeout 15

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
@synthesize successView;
@synthesize loadingView;
@synthesize sectionHeader;
@synthesize timeoutView;
@synthesize retryButton;
@synthesize foilButton;
@synthesize productId;
@synthesize prices;
@synthesize foilPrices;
@synthesize showFoilsOnly;
@synthesize firstRequestMade;

// ----------------------------------------------------------------------------

- (NSString *) strippedHTML:(NSString *)html {
    NSError *error;
    html = [html stringByReplacingOccurrencesOfRegex:@"<script.*?<\\/script>" withString:@"<noscript></noscript>" options:RKLDotAll range:NSMakeRange(0, html.length) error:&error];
    html = [html stringByReplacingOccurrencesOfRegex:@"<(\\/)?(?i:link)\\s" withString:@"<$1fink " options:RKLDotAll range:NSMakeRange(0, html.length) error:&error];
    html = [html stringByReplacingOccurrencesOfRegex:@"src=\"[^\"]+\"" withString:@"src=\"#\"" options:RKLDotAll range:NSMakeRange(0, html.length) error:&error];
    return html;
}

// ----------------------------------------------------------------------------

- (void) setProductId:(NSString *)theProductId {
    productId = theProductId;    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kRequestTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.prices == nil) {
            [self.webView stopLoading];
            self.firstRequestMade = NO;
            self.loadingView.hidden = YES;
            self.timeoutView.hidden = NO;
            [gAppDelegate trackEvent:@"All Prices" action:@"Failed" label:@"Timeout"];
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = [NSString stringWithFormat:@"http://store.tcgplayer.com/product.aspx?id=%@", productId];
        NSData *response = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (!response) {
            self.firstRequestMade = NO;
            self.loadingView.hidden = YES;
            self.timeoutView.hidden = NO;
            [gAppDelegate trackEvent:@"All Prices" action:@"Failed" label:@"No Response"];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *base = [NSURL URLWithString:@"http://store.tcgplayer.com/"];
                NSString *html = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                [self.webView loadHTMLString:[self strippedHTML:html] baseURL:base];
            });
        }
    });
}

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = [PriceVendorCell height];
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
        [self.foilButton setTitle:@"Foils"];
    } else {
        [self.foilButton setTitle:@"Any"];
    }
    self.showFoilsOnly = !self.showFoilsOnly;
    [self.tableView reloadData];
}

// ----------------------------------------------------------------------------

- (IBAction) retryButtonTapped:(id)sender {
    [gAppDelegate trackEvent:@"All Prices" action:@"Retry" label:@""];
    self.timeoutView.hidden = YES;
    self.loadingView.hidden = NO;
    self.productId = self.productId; // triggers data load
}

// ----------------------------------------------------------------------------

- (IBAction) doneButtonTapped:(id)sender {
    [gAppDelegate.rootController dismissModalViewControllerAnimated:YES];
}

// ----------------------------------------------------------------------------

- (IBAction) tcgButtonTapped:(id)sender {
    [gAppDelegate trackEvent:@"All Prices" action:@"Show TCGPlayer" label:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
        [NSString stringWithFormat:@"http://store.tcgplayer.com/product.aspx?id=%@&partner=ORCSHLBRN", self.productId]]];    
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }     
    cell.vendor = [self.currentPrices objectAtIndex:indexPath.row];
    return cell;
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
    [self.webView stringByEvaluatingJavaScriptFromString:@"(function(){ var s = document.createElement('script'); s.src = 'http://orcish.info/scripts/prices.js'; document.getElementsByTagName('head')[0].appendChild(s); })()"];
}

// ----------------------------------------------------------------------------

@end
