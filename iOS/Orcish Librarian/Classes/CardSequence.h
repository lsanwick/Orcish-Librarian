//
//  CardSequence.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/25/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@interface CardSequence : NSObject

+ (CardSequence *) sequenceWithCards:(NSArray *)cards;
+ (CardSequence *) randomCardSequence;
- (Card *) cardAtPosition:(NSUInteger)position;

@property (nonatomic, readonly) NSUInteger count;

@end
