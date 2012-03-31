//
//  PriceManager.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 3/30/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PriceManager : NSObject

+ (PriceManager *) shared;
- (void) clearPriceRequests;
- (void) queuePriceRequests:(NSArray *)cards;

@end
