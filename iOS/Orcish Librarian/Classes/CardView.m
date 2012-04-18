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

- (void) setCard:(Card *)theCard {
    card = theCard;
    if (self.isDoneLoading) {        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Orcish.setCardData(%@)", [card toJSON]]];
        });
    }
}

// ----------------------------------------------------------------------------
//  UIWebViewDelegate
// ----------------------------------------------------------------------------

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];    
    if ([URL.scheme isEqualToString:@"card"]) {
        NSString *pk = URL.host;
        Card *newCard = [Card findCardByPk:pk];
        if (newCard != nil) {            
            [gAppDelegate showCard:newCard];
        } 
        return NO;
    } else if ([URL.scheme isEqualToString:@"done"]) {
        if (card != nil) {              
            self.card = card;
        }
    }
    return YES;
}

// ----------------------------------------------------------------------------

@end
