//
//  RandomCardSequence.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/28/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RandomCardSequence.h"
#import "Card.h"

#define kRandomSequenceLength 12000


@interface RandomCardSequence () 

@property (nonatomic, strong) NSMutableDictionary *cards;

@end


@implementation RandomCardSequence

@synthesize cards;

// ----------------------------------------------------------------------------

- (id) init {
    if (self = [super init]) {
        self.cards = [NSMutableDictionary dictionary];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (id) initWithCards:(NSArray *)cards {
    assert(false);
}

// ----------------------------------------------------------------------------

- (Card *) cardAtPosition:(NSUInteger)position {
    NSNumber *positionAsObject = [NSNumber numberWithUnsignedInteger:position];        
    id pk = [self.cards objectForKey:positionAsObject];
    if (!pk) {
        Card *randomCard = [Card findRandomCard];
        [self.cards setObject:[NSNumber numberWithUnsignedInteger:randomCard.pk] forKey:positionAsObject];
        return randomCard;
    } else {
        return [Card findCardByPk:[pk unsignedIntegerValue]];   
    }
}

// ----------------------------------------------------------------------------

- (NSUInteger) count {
    return kRandomSequenceLength;
}

// ----------------------------------------------------------------------------

@end
