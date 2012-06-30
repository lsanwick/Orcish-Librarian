//
//  Facet.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/24/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacetCategory.h"


@interface Facet : NSObject

+ (Facet *) facetWithCard:(NSUInteger)cardPk;
+ (Facet *) facetWithIndex:(NSUInteger)cardIdx;
+ (Facet *) facetWithTitleText:(NSString *)text;
+ (Facet *) facetWithOracleText:(NSString *)text;
+ (Facet *) facetWithType:(NSString *)text;
+ (Facet *) facetWithRarity:(FacetRarity)rarity;
+ (Facet *) facetWithSet:(NSUInteger)setPk;
+ (Facet *) facetWithBlock:(NSUInteger)blockPk;
+ (Facet *) facetWithFormat:(FacetFormat)format;
+ (Facet *) facetWithColors:(FacetColor)color, ...;
+ (Facet *) facetWithPower:(NSUInteger)power;
+ (Facet *) facetWithToughness:(NSUInteger)toughness;
+ (Facet *) facetWithConvertedManaCost:(NSUInteger)cost;

- (void) updateSearchClauses:(NSMutableArray *)searchClauses withParams:(NSMutableArray *)searchParams andOrderClauses:(NSMutableArray *)orderClauses withParams:(NSMutableArray *)orderParams;

- (FacetCategory *) category;

@end
