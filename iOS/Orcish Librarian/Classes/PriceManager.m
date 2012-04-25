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


@interface QueuedLookup : NSObject
@property (nonatomic, strong) PriceCallback callback;
@property (nonatomic, strong) Card *card;
@end
@implementation QueuedLookup
@synthesize callback;
@synthesize card;
@end


@interface PriceManager () {
    NSMutableArray *queue;
    NSMutableDictionary *prices;
    NSUInteger pendingRequests;
}

- (void) downloadQueuedPrices;
- (void) beginLookup:(QueuedLookup *)lookup;

@end

@implementation PriceManager

// ----------------------------------------------------------------------------
//  PUBLIC METHODS
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

- (void) clearPriceRequests {
    [queue removeAllObjects];
}

// ----------------------------------------------------------------------------

- (NSDictionary *) priceForCard:(Card *)card {
    return [prices objectForKey:card.pk];
}

// ----------------------------------------------------------------------------

- (void) requestPriceForCard:(Card *)card withCallback:(PriceCallback)callback {
    NSDictionary *price = [self priceForCard:card];
    if (price) {
        callback(card, price);
    } else {
        QueuedLookup *lookup = [[QueuedLookup alloc] init];
        lookup.callback = callback;
        lookup.card = card;    
        [queue addObject:lookup];
        [self downloadQueuedPrices];
    }
}

// ----------------------------------------------------------------------------
//  PRIVATE METHODS
// ----------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        queue = [NSMutableArray array];
        prices = [NSMutableDictionary dictionary];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (void) downloadQueuedPrices {
    while (pendingRequests < kDownloadBatchSize && queue.count > 0) {
        [self beginLookup:[queue lastObject]];
        [queue removeLastObject];
        pendingRequests++;
    }
}

// ----------------------------------------------------------------------------

- (void) beginLookup:(QueuedLookup *)lookup {
    NSString *cardName = [lookup.card.displayName stringByReplacingOccurrencesOfRegex:@"^.*\\((.*)\\s\\/\\/\\s(.*)\\)$" withString:@"$1 // $2"];
    NSString *url = [NSString stringWithFormat:@"http://partner.tcgplayer.com/x/phl.asmx/p?pk=ORCSHLBRN&p=%@&s=%@",
        [cardName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
        [lookup.card.tcgSetName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            pendingRequests--;
            if (response != nil) {
                NSDictionary *price = [self priceForResponse:response];
                if (price != nil) {
                    [prices setObject:price forKey:lookup.card.pk];
                    lookup.callback(lookup.card, price);
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

- (void) announceNewPrice:(NSDictionary *)price forCard:(Card *)card {
    NSLog(@"\n------------------------\nPrice for %@: %@", card.name, price);
    
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
