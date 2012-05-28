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

@property (nonatomic, assign) NSUInteger versionCount;
@property (nonatomic, assign) NSUInteger pk;
@property (nonatomic, assign) NSUInteger nameHash;
@property (nonatomic, assign) NSUInteger gathererId;
@property (nonatomic, assign) NSUInteger setPk;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *searchName;
@property (nonatomic, strong) NSString *tcgName;
@property (nonatomic, strong) NSString *setName;
@property (nonatomic, strong) NSString *tcgSetName;
@property (nonatomic, strong) NSString *collectorNumber;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *artIndex;
@property (nonatomic, strong) NSString *rarity;
@property (nonatomic, strong) NSString *manaCost;
@property (nonatomic, strong) NSString *typeLine;
@property (nonatomic, strong) NSString *oracleText;
@property (nonatomic, strong) NSString *power;
@property (nonatomic, strong) NSString *toughness;
@property (nonatomic, strong) NSString *loyalty;
@property (nonatomic, readonly) NSArray *artVariants;
@property (nonatomic, readonly) NSArray *otherEditions;
@property (nonatomic, readonly) NSArray *otherParts;

@property (nonatomic, assign) BOOL isBookmarked;

+ (Card *) cardForResultSet:(FMResultSet *)resultSet;
+ (NSArray *) collapseCardList:(NSArray *)cards;
+ (NSArray *) findCardsByTitleText:(NSString *)text;
+ (NSArray *) findCardsBySet:(NSUInteger)setPk;
+ (NSArray *) findCards:(SearchCriteria *)criteria;
+ (NSArray *) findNameHashesByText:(NSString *)text;
+ (NSArray *) findBookmarkedCards;
+ (Card *) findCardByPk:(NSUInteger)pk;
+ (Card *) findRandomCard;

- (NSString *) toJSON;

@end
