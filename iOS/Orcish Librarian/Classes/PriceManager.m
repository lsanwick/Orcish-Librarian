//
//  PriceManager.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 3/30/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "PriceManager.h"
#import "Card.h"
#import "RegexKitLite.h"


#define kDownloadBatchSize 3


@interface PriceManager () {
    NSMutableArray *queue;
    NSMutableDictionary *prices;
    NSUInteger pendingRequests;
}

- (void) downloadQueuedPrices;
- (void) beginPriceDownloadForCard:(Card *)card;
- (NSString *) tcgNameForCard:(Card *)card;
- (NSString *) tcgSetForCard:(Card *)card;

@end

@implementation PriceManager

// ----------------------------------------------------------------------------

+ (PriceManager *) shared {
    static PriceManager *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[PriceManager alloc] init];
    });
    return singleton;
}

// ----------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        queue = [NSMutableArray array];
        prices = [NSMutableDictionary dictionary];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (void) clearPriceRequests {
    [queue removeAllObjects];
}

// ----------------------------------------------------------------------------

- (void) queuePriceRequests:(NSArray *)cards {
    for (Card *card in [cards reverseObjectEnumerator]) {
        if ([prices objectForKey:card.pk] == nil) {
            [queue addObject:card];
        }
    }
    [self downloadQueuedPrices];
}

// ----------------------------------------------------------------------------

- (void) downloadQueuedPrices {
    while (pendingRequests < kDownloadBatchSize && queue.count > 0) {
        [self beginPriceDownloadForCard:[queue objectAtIndex:0]];
        [queue removeObjectAtIndex:0];
        pendingRequests++;
    }
}

// ----------------------------------------------------------------------------

- (void) beginPriceDownloadForCard:(Card *)card {
    NSString *url = [NSString stringWithFormat:@"http://partner.tcgplayer.com/x/phl.asmx/p?pk=ORCSHLBRN&p=%@&s=%@",
        [[self tcgNameForCard:card] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        [[self tcgSetForCard:card] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            pendingRequests--;
            if (response != nil) {
                NSDictionary *price = [self priceForResponse:response];
                if (price != nil) {
                    [prices setObject:price forKey:card.pk];
                    NSLog(@"%@: %@", card.name, price);
                } else {
                    NSLog(@"Could not find price for %@", card.name);
                }
            }
            [self downloadQueuedPrices];
        });
    });
}

// ----------------------------------------------------------------------------

- (NSDictionary *) priceForResponse:(NSData *)response {
    NSString *text = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSArray *tcgId = [text arrayOfCaptureComponentsMatchedByRegex:@"id&gt;(\\d+)"];    
    NSArray *high = [text arrayOfCaptureComponentsMatchedByRegex:@"hiprice&gt;(\\d+\\.\\d+)"];
    NSArray *average = [text arrayOfCaptureComponentsMatchedByRegex:@"avgprice&gt;(\\d+\\.\\d+)"];
    NSArray *low = [text arrayOfCaptureComponentsMatchedByRegex:@"lowprice&gt;(\\d+\\.\\d+)"];
    if (high.count == 1 && average.count == 1 && low.count == 1 && tcgId.count == 1) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithFormat:@"%.2f", [[[low objectAtIndex:0] objectAtIndex:1] floatValue]], @"low",
            [NSString stringWithFormat:@"%.2f", [[[average objectAtIndex:0] objectAtIndex:1] floatValue]], @"average",
            [NSString stringWithFormat:@"%.2f", [[[high objectAtIndex:0] objectAtIndex:1] floatValue]], @"high",
            [[tcgId objectAtIndex:0] objectAtIndex:1], @"tcgId",
            nil];
    }
    return nil;
}

// ----------------------------------------------------------------------------

- (NSString *) tcgNameForCard:(Card *)card {
    return card.name;
}

// ----------------------------------------------------------------------------

- (NSString *) tcgSetForCard:(Card *)card {
    return card.setName;
}

// ----------------------------------------------------------------------------

@end
