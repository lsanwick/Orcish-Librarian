//
//  CardSequence.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/28/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "CardSequence.h"
#import "Card.h"

@implementation CardSequence

// ----------------------------------------------------------------------------

- (Card *) cardAtPosition:(NSUInteger)position {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
        userInfo:nil];
}

// ----------------------------------------------------------------------------

- (NSUInteger) count {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
        userInfo:nil];
}

// ----------------------------------------------------------------------------

- (NSUInteger) positionOfCardMatchingName:(NSString *)name {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
        userInfo:nil];
}

// ----------------------------------------------------------------------------

- (void) hydrate {
    // nothing by default
}

// ----------------------------------------------------------------------------

- (void) dehydrate {
    // nothing by default
}

// ----------------------------------------------------------------------------

@end
