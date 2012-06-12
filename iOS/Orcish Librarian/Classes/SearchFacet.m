//
//  SearchFacet.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/24/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"
#import "SearchFacet.h"
#import "RegexKitLite.h"
#import "Card.h"


@interface SearchFacet ()

+ (NSString *) sanitizedSearchString:(NSString *)text;
- (id) initWithCategory:(SearchFacetCategory)facetCategory;
- (NSArray *) findNameHashesByText:(NSString *)text;

@property (nonatomic, assign) SearchFacetCategory category;
@property (nonatomic, strong) NSMutableDictionary *storage;

@end

@implementation SearchFacet

@synthesize category;
@synthesize storage;

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithCard:(NSUInteger)cardPk {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetCard];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:cardPk] forKey:@"cardPk"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithIndex:(NSUInteger)cardIdx {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetIndex];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:cardIdx] forKey:@"cardIdx"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithTitleText:(NSString *)text {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetTitleText];
    [facet.storage setObject:[self sanitizedSearchString:text] forKey:@"titleText"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithOracleText:(NSString *)text {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetOracleText];
    [facet.storage setObject:text forKey:@"oracleText"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithType:(NSString *)text {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetType];
    [facet.storage setObject:text forKey:@"type"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithRarity:(SearchFacetRarity)rarity {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetRarity];
    [facet.storage setObject:[NSNumber numberWithInt:rarity] forKey:@"rarity"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithSet:(NSUInteger)setPk {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetSet];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:setPk] forKey:@"setPk"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithBlock:(NSUInteger)blockPk {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetBlock];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:blockPk] forKey:@"blockPk"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithFormat:(SearchFacetFormat)format {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetFormat];
    [facet.storage setObject:[NSNumber numberWithInt:format] forKey:@"format"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithColors:(SearchFacetColor)color, ... {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetColors];
    
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithPower:(NSUInteger)power {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetPower];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:power] forKey:@"power"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithToughness:(NSUInteger)toughness {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetToughness];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:toughness] forKey:@"toughness"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (SearchFacet *) facetWithConvertedManaCost:(NSUInteger)cost {
    SearchFacet *facet = [[SearchFacet alloc] initWithCategory:kSearchFacetCMC];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:cost] forKey:@"cmc"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (NSString *) sanitizedSearchString:(NSString *)text {
    text = [text uppercaseString]; // all upper-case
    text = [text stringByReplacingOccurrencesOfRegex:@"\\(.*?\\)" withString:@""]; // remove parenthetical text
    text = [text stringByReplacingOccurrencesOfRegex:@"[^A-Z]" withString:@""]; // remove non-alphanumeric characters
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // trim whitespace
    return text;
}

// ----------------------------------------------------------------------------

- (void) updateSearchClauses:(NSMutableArray *)searchClauses withParams:(NSMutableArray *)searchParams andOrderClauses:(NSMutableArray *)orderClauses withParams:(NSMutableArray *)orderParams {
    switch (self.category) {

        // specific card
        case kSearchFacetCard: {
            [searchClauses addObject:@"cards.pk = ?"];
            [searchParams addObject:[self.storage objectForKey:@"cardPk"]];
            break;
        }
            
        // specific index
        case kSearchFacetIndex: {
            [searchClauses addObject:@"cards.idx = ?"];
            [searchParams addObject:[self.storage objectForKey:@"cardIdx"]];
            break;
        }
            
        // specific set
        case kSearchFacetSet: {
            [searchClauses addObject:@"sets.pk = ?"];
            [searchParams addObject:[self.storage objectForKey:@"setPk"]];
            break;
        }
            
        // title text
        case kSearchFacetTitleText: {
            NSString *text = [self.storage objectForKey:@"titleText"];
            if (text != nil && text.length >= kMinimumSearchCharacters) {
                NSArray *nameHashes = [self findNameHashesByText:text];
                if (nameHashes.count > 0) {
                    NSMutableArray *marks = [NSMutableArray arrayWithCapacity:nameHashes.count];
                    for (int i = 0; i < nameHashes.count; i++) {
                        [marks addObject:@"?"];
                    }
                    [searchClauses addObject:[NSString stringWithFormat:@"cards.name_hash IN (%@)", [marks componentsJoinedByString:@", "]]];
                    [searchParams addObjectsFromArray:nameHashes];
                    [orderClauses addObject:[NSString stringWithFormat:@"(SUBSTR(cards.search_name, 0, %d) = ?) DESC", text.length + 1]];
                    [orderParams addObject:text];
                }
            }
            break;            
        }
            
        // 

        default:
            break;
    }
}

// ----------------------------------------------------------------------------

- (id) init {
    return [self initWithCategory:kSearchFacetEmpty];
}

// ----------------------------------------------------------------------------

- (id) initWithCategory:(SearchFacetCategory)facetCategory {
    if (self = [super init]) {
        self.category = facetCategory;
        self.storage = [NSMutableDictionary dictionary];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (NSArray *) findNameHashesByText:(NSString *)text {
    NSMutableArray *hashes = [NSMutableArray array];
    if (text.length < kMinimumSearchCharacters) { return [NSArray array]; }
    text = [text uppercaseString];
    dispatch_sync(gAppDelegate.dataQueue, ^{
        NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
        NSData *blob = gDataManager.names;
        const char *blobText = blob.bytes;
        NSRange scope = NSMakeRange(0, blob.length);
        NSRange instance;
        NSUInteger pkStart, pkEnd;
        while (true) {
            instance = [blob rangeOfData:textData options:0 range:scope];
            if(instance.location == NSNotFound) { break; }
            pkStart = instance.location;
            while (blobText[pkStart] != '|') { ++pkStart; }
            pkEnd = ++pkStart;
            while (blobText[pkEnd] != '|') { ++pkEnd; }        
            scope = NSMakeRange(pkEnd, blob.length - pkEnd);
            NSString *hashAsString = [[NSString alloc] initWithBytes:&blobText[pkStart] length:(pkEnd-pkStart) encoding:NSUTF8StringEncoding];
            [hashes addObject:[NSNumber numberWithUnsignedInteger:[hashAsString longLongValue]]];
        }
    });
    return hashes;
}

// ----------------------------------------------------------------------------

@end
