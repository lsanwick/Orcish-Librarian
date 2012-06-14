//
//  Card.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/12/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMinimumSearchCharacters 3

@class CardSequence;
@class FMResultSet;

@interface Card : NSObject 

@property (nonatomic, assign) NSUInteger pk;
@property (nonatomic, assign) NSUInteger nameHash;
@property (nonatomic, assign) NSUInteger gathererId;
@property (nonatomic, assign) NSUInteger setPk;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *searchName;
@property (nonatomic, strong) NSString *tcgName;
@property (nonatomic, strong) NSString *setName;
@property (nonatomic, strong) NSString *setDisplayName;
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

+ (CardSequence *) findCardsByTitleText:(NSString *)text;
+ (CardSequence *) findCardsBySet:(NSUInteger)setPk;
+ (CardSequence *) findCards:(NSArray *)facets;
+ (CardSequence *) findBookmarkedCards;
+ (Card *) findCardByPk:(NSUInteger)pk;
+ (Card *) findRandomCard;
+ (Card *) cardForResultSet:(FMResultSet *)resultSet;

- (NSString *) toJSON;

@end
