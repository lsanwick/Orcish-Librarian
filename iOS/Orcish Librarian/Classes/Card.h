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
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *searchName;
@property (nonatomic, strong) NSString *nameHash;
@property (nonatomic, strong) NSString *gathererId;
@property (nonatomic, strong) NSString *setPk;
@property (nonatomic, strong) NSString *setName;
@property (nonatomic, strong) NSString *tcgSetName;
@property (nonatomic, strong) NSString *collectorNumber;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *artIndex;
@property (nonatomic, strong) NSString *rarity;
@property (nonatomic, strong) NSString *manaCost;
@property (nonatomic, strong) NSString *typeLine;
@property (nonatomic, assign) BOOL isToken;
@property (nonatomic, strong) NSString *oracleText;
@property (nonatomic, strong) NSString *power;
@property (nonatomic, strong) NSString *toughness;
@property (nonatomic, strong) NSString *loyalty;
@property (nonatomic, assign) NSUInteger versionCount;
@property (nonatomic, readonly) NSArray *artVariants;
@property (nonatomic, readonly) NSArray *otherEditions;
@property (nonatomic, readonly) NSArray *otherParts;

+ (Card *) cardForResultSet:(FMResultSet *)resultSet;
+ (NSArray *) findCardsByTitleText:(NSString *)text;
+ (NSArray *) findCards:(SearchCriteria *)criteria;
+ (NSArray *) findNameHashesByText:(NSString *)text;
+ (Card *) findCardByPk:(NSString *)pk;

- (NSString *) toJSON;

@end
