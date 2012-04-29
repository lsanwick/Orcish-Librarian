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
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:price options:0 error:&error] encoding:NSUTF8StringEncoding];
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Orcish.setCardPrice(%@, %@)", card.pk, json]];
}

// ----------------------------------------------------------------------------

- (void) setCard:(Card *)theCard {
    card = theCard;
    if (self.isDoneLoading) {        
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
    NSURL *URL = [request URL];    
    if ([URL.scheme isEqualToString:@"set"]) {
        NSArray *cards = [Card findCardsBySet:URL.host];
        [gAppDelegate showCards:cards atPosition:[cards indexOfObjectPassingTest:^(Card *test, NSUInteger index, BOOL *stop) {
            return (BOOL) ([self.card.nameHash isEqualToString:test.nameHash] ? (*stop = YES) : NO);
        }]];
    } else if ([URL.scheme isEqualToString:@"card"]) {
        NSString *pk = URL.host;
        Card *newCard = [Card findCardByPk:pk];
        if (newCard != nil) {            
            [gAppDelegate showCard:newCard];
        } 
    } else if ([URL.scheme isEqualToString:@"done"]) {
        if (card != nil) {              
            self.card = card;
        }
    } else if ([URL.scheme isEqualToString:@"price"]) {
        [[PriceManager shared] requestPriceForCard:self.card withCallback:^(Card *theCard, NSDictionary *price) {
            [self setPrice:price forCard:theCard];
        }];
    } else {
        return YES;
    }
    return NO;
}

// ----------------------------------------------------------------------------

@end
