//
//  SearchFacet.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/24/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    kSearchFacetEmpty,
    kSearchFacetCard,
    kSearchFacetIndex,
    kSearchFacetTitleText,
    kSearchFacetOracleText,
    kSearchFacetRarity,
    kSearchFacetSet,
    kSearchFacetBlock,
    kSearchFacetFormat,
    kSearchFacetColors,
    kSearchFacetType,
    kSearchFacetCMC,
    kSearchFacetPower,
    kSearchFacetToughness,
    kSearchFacetSortOrder
} SearchFacetCategory;

typedef enum {
    kSearchFacetRarityAny,
    kSearchFacetRarityLand,
    kSearchFacetRarityCommon,
    kSearchFacetRarityUncommon,
    kSearchFacetRarityRare,
    kSearchFacetRarityMythic,
    kSearchFacetRaritySpecial
} SearchFacetRarity;

typedef enum {
    kSearchFacetFormatAny,
    kSearchFacetFormatStandard,
    kSearchFacetFormatModern,
    kSearchFacetFormatLegacy,
    kSearchFacetFormatVintage,
    kSearchFacetFormatCommander
} SearchFacetFormat;

typedef enum {
    kSearchFacetColorAny,
    kSearchFacetColorColorless,
    kSearchFacetColorWhite,
    kSearchFacetColorBlue,
    kSearchFacetColorBlack,
    kSearchFacetColorRed,
    kSearchFacetColorGreen
} SearchFacetColor;

#define kPowerToughnessStar NSUIntegerMax

typedef enum {
    kSearchFacetSortNone,
    kSearchFacetSortAlphabetical,
    kSearchFacetSortRandom    
} SearchFacetSortOrder;


@interface SearchFacet : NSObject

+ (SearchFacet *) facetWithCard:(NSUInteger)cardPk;
+ (SearchFacet *) facetWithIndex:(NSUInteger)cardIdx;
+ (SearchFacet *) facetWithTitleText:(NSString *)text;
+ (SearchFacet *) facetWithOracleText:(NSString *)text;
+ (SearchFacet *) facetWithType:(NSString *)text;
+ (SearchFacet *) facetWithRarity:(SearchFacetRarity)rarity;
+ (SearchFacet *) facetWithSet:(NSUInteger)setPk;
+ (SearchFacet *) facetWithBlock:(NSUInteger)blockPk;
+ (SearchFacet *) facetWithFormat:(SearchFacetFormat)format;
+ (SearchFacet *) facetWithColors:(SearchFacetColor)color, ...;
+ (SearchFacet *) facetWithPower:(NSUInteger)power;
+ (SearchFacet *) facetWithToughness:(NSUInteger)toughness;
+ (SearchFacet *) facetWithConvertedManaCost:(NSUInteger)cost;
+ (NSString *) stringFromCategory:(SearchFacetCategory)category;

- (void) updateSearchClauses:(NSMutableArray *)searchClauses withParams:(NSMutableArray *)searchParams andOrderClauses:(NSMutableArray *)orderClauses withParams:(NSMutableArray *)orderParams;

@property (nonatomic, readonly) SearchFacetCategory category;

@end
