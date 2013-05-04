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
#import "NSString+URLEncoder.h"


#define kDownloadBatchSize 3
#define kMaxCacheAge 172800 // 60 * 60 * 24 * 2 => 48 hours


@interface QueuedLookup : NSObject
@property (nonatomic, strong) PriceCallback callback;
@property (nonatomic, strong) Card *card;
@end
@implementation QueuedLookup
@synthesize callback;
@synthesize card;
@end


@interface PriceManager () 

- (void) downloadQueuedPrices;
- (void) beginLookup:(QueuedLookup *)lookup;

@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) NSMutableDictionary *prices;
@property (nonatomic, assign) NSUInteger pendingRequests;

@end

@implementation PriceManager

@synthesize queue;
@synthesize prices;
@synthesize pendingRequests;

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
    return [self.prices objectForKey:[[NSNumber numberWithUnsignedInteger:card.pk] stringValue]];
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
        [self.queue addObject:lookup];
        [self downloadQueuedPrices];
    }
}

// ----------------------------------------------------------------------------

- (void) saveCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.prices forKey:@"prices"];
    [defaults synchronize];
}

// ----------------------------------------------------------------------------

- (void) loadCache {
    NSDictionary *cachedPrices = [[NSUserDefaults standardUserDefaults] objectForKey:@"prices"];
    if (cachedPrices != nil && [cachedPrices isKindOfClass:[NSDictionary class]]) {
        self.prices = [cachedPrices mutableCopy];
    }
}

// ----------------------------------------------------------------------------

- (void) clearCache {
    self.prices = [NSMutableDictionary dictionary];
}

// ----------------------------------------------------------------------------

- (void) pruneCache {
    NSDate *now = [NSDate date];
    NSMutableArray *deadPrices = [NSMutableArray array];
    for (NSString *pk in self.prices) {
        NSDate *cacheDate = [[self.prices objectForKey:pk] objectForKey:@"cacheDate"];
        if ([now timeIntervalSinceDate:cacheDate] > kMaxCacheAge) {
            [deadPrices addObject:pk];
        }
    }
    [self.prices removeObjectsForKeys:deadPrices];
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
    NSString *url = [NSString stringWithFormat:@"http://partner.tcgplayer.com/x3/phl.asmx/p?pk=ORCSHLBRN&p=%@&s=%@",
        [lookup.card.tcgName stringByEncodingForURL], [lookup.card.tcgSetName stringByEncodingForURL]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *response = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            pendingRequests--;
            if (response != nil) {
                NSDictionary *price = [self priceForResponse:response];
                if (price != nil) {
                    [prices setObject:price forKey:[[NSNumber numberWithUnsignedInteger:lookup.card.pk] stringValue]];
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
    NSArray *tcgId = [text arrayOfCaptureComponentsMatchedByRegex:@"<id>(\\d+)"];
    NSArray *high = [text arrayOfCaptureComponentsMatchedByRegex:@"<hiprice>(\\d+\\.\\d+)"];
    NSArray *average = [text arrayOfCaptureComponentsMatchedByRegex:@"<avgprice>(\\d+\\.\\d+)"];
    NSArray *low = [text arrayOfCaptureComponentsMatchedByRegex:@"<lowprice>(\\d+\\.\\d+)"];
    if (high.count == 1 && average.count == 1 && low.count == 1 && tcgId.count == 1) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDate date], @"cacheDate",
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
