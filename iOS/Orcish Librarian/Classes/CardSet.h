//
//  CardSet.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/9/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardSet : NSObject

+ (NSArray *) findStandardSets;
+ (NSArray *) findAll;

@property (nonatomic, assign) NSUInteger pk;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSArray *cards;

@end
