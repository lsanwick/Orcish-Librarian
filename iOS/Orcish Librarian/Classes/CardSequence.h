//
//  CardSequence.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/28/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@interface CardSequence : NSObject

- (Card *) cardAtPosition:(NSUInteger)position;
- (NSUInteger) count;
- (void) hydrate;
- (void) dehydrate;

@end
