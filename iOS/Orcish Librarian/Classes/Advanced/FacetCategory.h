//
//  FacetCategory.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/26/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    kFacetCard,
    kFacetIndex,
    kFacetTitleText,
    kFacetOracleText,
    kFacetRarity,
    kFacetSet,
    kFacetBlock,
    kFacetFormat,
    kFacetColors,
    kFacetType,
    kFacetCMC,
    kFacetPower,
    kFacetToughness,
    kFacetLoyalty
} FacetCategoryIdentifier;

typedef enum {
    kSearchFacetRarityAny,
    kSearchFacetRarityLand,
    kSearchFacetRarityCommon,
    kSearchFacetRarityUncommon,
    kSearchFacetRarityRare,
    kSearchFacetRarityMythic,
    kSearchFacetRaritySpecial
} FacetRarity;

typedef enum {
    kFacetFormatAny,
    kFacetFormatStandard,
    kFacetFormatModern,
    kFacetFormatLegacy,
    kFacetFormatVintage,
    kFacetFormatCommander
} FacetFormat;

typedef enum {
    kFacetColorAny,
    kFacetColorColorless,
    kFacetColorWhite,
    kFacetColorBlue,
    kFacetColorBlack,
    kFacetColorRed,
    kFacetColorGreen
} FacetColor;

#define kPowerToughnessStar NSUIntegerMax

typedef enum {
    kFacetSortNone,
    kFacetSortAlphabetical,
    kFacetSortRandom    
} FacetSortOrder;


@interface FacetCategory : NSObject

+ (FacetCategory *) card;
+ (FacetCategory *) index;
+ (FacetCategory *) titleText;
+ (FacetCategory *) oracleText;
+ (FacetCategory *) rarity;
+ (FacetCategory *) set;
+ (FacetCategory *) block;
+ (FacetCategory *) format;
+ (FacetCategory *) colors;
+ (FacetCategory *) type;
+ (FacetCategory *) convertedManaCost;
+ (FacetCategory *) power;
+ (FacetCategory *) toughness;
+ (FacetCategory *) loyalty;

- (FacetCategoryIdentifier) identifier;
- (NSString *) description;

@end
