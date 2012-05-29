//
//  StaticCardSequence.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/25/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardSequence.h"

@interface StaticCardSequence : CardSequence

- (id) initWithCards:(NSArray *)cards;

@end
