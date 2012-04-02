//
//  PriceManager.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 3/30/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

typedef void (^PriceCallback)(Card *, NSDictionary *);

@interface PriceManager : NSObject

+ (PriceManager *) shared;
- (NSDictionary *) priceForCard:(Card *)card;
- (void) requestPriceForCard:(Card *)card withCallback:(PriceCallback)callback;
- (void) clearPriceRequests;

@end
