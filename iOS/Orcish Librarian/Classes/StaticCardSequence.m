//
//  StaticCardSequence.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/25/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "StaticCardSequence.h"
#import "Card.h"


@interface StaticCardSequence () 

@property (nonatomic, strong) NSArray *cards;

@end


@implementation StaticCardSequence

@synthesize cards;

// ----------------------------------------------------------------------------

- (id) initWithCards:(NSArray *)theCards {
    if (self = [super init]) {
        self.cards = [theCards copy];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (Card *) cardAtPosition:(NSUInteger)position {
    return [self.cards objectAtIndex:position];
}

// ----------------------------------------------------------------------------

- (NSUInteger) count {
    return self.cards.count;
}

// ----------------------------------------------------------------------------

@end
