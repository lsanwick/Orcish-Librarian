//
//  CardView.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/17/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "CardView.h"
#import "Card.h"
#import "AppDelegate.h"
#import "PriceManager.h"

@interface CardView ()

@property (nonatomic, readonly) BOOL isDoneLoading;

@end


@implementation CardView

@synthesize card;

// ----------------------------------------------------------------------------

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
    }
    return self;
}

// ----------------------------------------------------------------------------

- (BOOL) isDoneLoading {
    return [[self stringByEvaluatingJavaScriptFromString:@"typeof Orcish.setCardData"] isEqualToString:@"function"];
}

// ----------------------------------------------------------------------------

- (void) setPrice:(NSDictionary *)price forCard:(Card *)theCard {
    NSError *error;
    NSMutableDictionary *priceData = [price mutableCopy];
    // remove the cache date, because you can't automatically make an NSDate into a JSON object
    // and we don't need it anyway
    [priceData removeObjectForKey:@"cacheDate"]; 
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:priceData options:0 error:&error] encoding:NSUTF8StringEncoding];
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Orcish.setCardPrice(%@, %@)", [NSNumber numberWithUnsignedInteger:card.pk], json]];
}

// ----------------------------------------------------------------------------

- (void) setCard:(Card *)theCard {
    card = theCard;
    if (theCard != nil && self.isDoneLoading) {        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            NSString *js = [NSString stringWithFormat:@"Orcish.setCardData(%@)", [card toJSON]];
            // NSLog(@"%@", js);
            [self stringByEvaluatingJavaScriptFromString:js];
            [[PriceManager shared] requestPriceForCard:card withCallback:^(Card *priceCard, NSDictionary *price) {
                [self setPrice:price forCard:card];
            }];
        });
    }
}

// ----------------------------------------------------------------------------
//  UIWebViewDelegate
// ----------------------------------------------------------------------------

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = request.URL;    
    
    // DONE LOADING WEBVIEW
    if ([URL.scheme isEqualToString:@"done"]) {
        self.card = self.card; // retriggers the JavaScript loader
    } 
    
    // SHOW ANOTHER SET
    else if ([URL.scheme isEqualToString:@"set"]) {        
        if ([URL.host isEqualToString:@"self"]) {
            // show the current card's set
            [gAppDelegate showCardList:[Card findCardsBySet:self.card.setPk] withTitle:self.card.setName];
        } else {
            // show the set from the current card's equivalent
            NSUInteger setPk = (NSUInteger) [URL.host longLongValue];
            [gAppDelegate showCards:[Card findCardsBySet:setPk] atPosition:0];
        }
    } 
    
    // SHOW SPECIFIC CARD
    else if ([URL.scheme isEqualToString:@"card"]) {        
        NSUInteger pk = (NSUInteger) [URL.host longLongValue];
        Card *newCard = [Card findCardByPk:pk];
        if (newCard != nil) {
            [gAppDelegate showCard:newCard];
        } 
    } 
    
    // LAUNCH GATHERER
    else if ([URL.scheme isEqualToString:@"gatherer"]) {
        [gAppDelegate trackEvent:@"Card View" action:@"Show Gatherer" label:@""];
        [gAppDelegate launchExternalSite:[NSURL URLWithString:[NSString stringWithFormat:
            @"http://gatherer.wizards.com/Pages/Card/Discussion.aspx?multiverseid=%@", 
            [NSNumber numberWithUnsignedInteger:self.card.gathererId]]]];
    } 
    
    // RELOAD PRICES
    else if ([URL.scheme isEqualToString:@"price"]) {
        [[PriceManager shared] requestPriceForCard:self.card withCallback:^(Card *theCard, NSDictionary *price) {
            [self setPrice:price forCard:theCard];
        }];
    } 
    
    // SHOW "ALL PRICES" MODAL
    else if ([URL.scheme isEqualToString:@"tcg"]) {
        [gAppDelegate trackEvent:@"Card View" action:@"Show All Prices" label:@""];
        [gAppDelegate showPriceModalForProductId:URL.host];
    } 
    
    // TOGGLE BOOKMARK 
    else if ([URL.scheme isEqualToString:@"bookmark"]) {        
        self.card.isBookmarked = [URL.host isEqualToString:@"on"];
    }
    
    // UNKNOWN COMMAND
    else {
        return YES;
    }
    
    return NO;
}

// ----------------------------------------------------------------------------

@end
