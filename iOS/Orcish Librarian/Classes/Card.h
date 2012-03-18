//
//  Card.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/12/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;
@class SearchCriteria;


@interface Card : NSObject 

@property (nonatomic, strong) NSString *pk;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gathererId;
@property (nonatomic, strong) NSString *setPk;
@property (nonatomic, strong) NSString *setName;
@property (nonatomic, strong) NSString *collectorNumber;
@property (nonatomic, strong) NSString *rarity;
@property (nonatomic, strong) NSString *manaCost;
@property (nonatomic, strong) NSString *typeLine;
@property (nonatomic, strong) NSString *oracleText;
@property (nonatomic, strong) NSString *power;
@property (nonatomic, strong) NSString *toughness;
@property (nonatomic, strong) NSString *loyalty;
@property (nonatomic, assign) NSUInteger versionCount;

+ (Card *) cardForResultSet:(FMResultSet *)resultSet;
+ (NSArray *) findCardsByTitleText:(NSString *)text;
+ (NSArray *) findCards:(SearchCriteria *)criteria;
+ (NSArray *) findNameHashesByText:(NSString *)text;

@end
