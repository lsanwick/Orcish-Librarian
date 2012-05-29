//
//  QueryCardSequence.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/28/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "CardSequence.h"

@interface QueryCardSequence : CardSequence

- (id) initWithQuery:(NSString *)sql;
- (id) initWithQuery:(NSString *)sql argumentsInArray:(NSArray *)arguments;
- (void) hydrate;
- (void) dehydrate;

@end
