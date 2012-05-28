//
//  CardSequence.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/25/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "CardSequence.h"
#import "Card.h"

#define kRandomSequenceLength 12000

@interface CardSequence()

@property (nonatomic, strong) NSArray *cards;
@property (nonatomic, strong) NSMutableDictionary *randomCards;

@end


@implementation CardSequence 

@synthesize cards;
@synthesize randomCards;

// ----------------------------------------------------------------------------

+ (CardSequence *) sequenceWithCards:(NSArray *)cards {
    CardSequence *sequence = [[CardSequence alloc] init];
    sequence.cards = cards;
    return sequence;
}

// ----------------------------------------------------------------------------

+ (CardSequence *) randomCardSequence {
    CardSequence *sequence = [[CardSequence alloc] init];
    sequence.randomCards = [NSMutableDictionary dictionary];
    return sequence;
}

// ----------------------------------------------------------------------------

- (Card *) cardAtPosition:(NSUInteger)position {
    if (self.randomCards) {
        NSNumber *positionAsObject = [NSNumber numberWithUnsignedInteger:position];        
        id pk = [self.randomCards objectForKey:positionAsObject];
        if (!pk) {
            Card *randomCard = [Card findRandomCard];
            [self.randomCards setObject:[NSNumber numberWithUnsignedInteger:randomCard.pk] forKey:positionAsObject];
            return randomCard;
        } else {
            return [Card findCardByPk:[pk unsignedIntegerValue]];   
        }
    } else {
        return [self.cards objectAtIndex:position];
    }    
}

// ----------------------------------------------------------------------------

- (NSUInteger) count {
    if (self.randomCards) {
        return kRandomSequenceLength;
    } else {
        return self.cards.count;
    }
}

// ----------------------------------------------------------------------------

@end
