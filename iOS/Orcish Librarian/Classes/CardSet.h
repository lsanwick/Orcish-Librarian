//
//  CardSet.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/9/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CardSequence;

@interface CardSet : NSObject

+ (NSArray *) findStandardSets;
+ (NSArray *) findAll;

@property (nonatomic, assign) NSUInteger pk;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, readonly) CardSequence *cards;

@end
