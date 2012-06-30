//
//  Facet.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/24/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"
#import "Facet.h"
#import "RegexKitLite.h"
#import "Card.h"


@interface Facet ()

+ (NSString *) sanitizedSearchString:(NSString *)text;
- (id) initWithCategory:(FacetCategory *)category;
- (NSArray *) findNameHashesByText:(NSString *)text;

@property (nonatomic, strong) FacetCategory *category;
@property (nonatomic, strong) NSMutableDictionary *storage;

@end

@implementation Facet

@synthesize category;
@synthesize storage;

// ----------------------------------------------------------------------------

+ (Facet *) facetWithCard:(NSUInteger)cardPk {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory card]];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:cardPk] forKey:@"cardPk"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithIndex:(NSUInteger)cardIdx {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory index]];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:cardIdx] forKey:@"cardIdx"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithTitleText:(NSString *)text {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory titleText]];
    [facet.storage setObject:text forKey:@"titleText"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithOracleText:(NSString *)text {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory oracleText]];
    [facet.storage setObject:text forKey:@"oracleText"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithType:(NSString *)text {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory type]];
    [facet.storage setObject:text forKey:@"type"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithRarity:(FacetRarity)rarity {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory rarity]];
    [facet.storage setObject:[NSNumber numberWithInt:rarity] forKey:@"rarity"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithSet:(NSUInteger)setPk {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory set]];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:setPk] forKey:@"setPk"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithBlock:(NSUInteger)blockPk {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory block]];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:blockPk] forKey:@"blockPk"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithFormat:(FacetFormat)format {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory format]];
    [facet.storage setObject:[NSNumber numberWithInt:format] forKey:@"format"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithColors:(FacetColor)color, ... {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory colors]];
    
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithPower:(NSUInteger)power {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory power]];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:power] forKey:@"power"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithToughness:(NSUInteger)toughness {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory toughness]];
    [facet.storage setObject:[NSNumber numberWithUnsignedInteger:toughness] forKey:@"toughness"];
    return facet;
}

// ----------------------------------------------------------------------------

+ (Facet *) facetWithConvertedManaCost:(NSUInteger)cost {
    Facet *facet = [[Facet alloc] initWithCategory:[FacetCategory convertedManaCost]];
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
    switch (self.category.identifier) {

        // specific card
        case kFacetCard: {
            [searchClauses addObject:@"cards.pk = ?"];
            [searchParams addObject:[self.storage objectForKey:@"cardPk"]];
            break;
        }
            
        // specific index
        case kFacetIndex: {
            [searchClauses addObject:@"cards.idx = ?"];
            [searchParams addObject:[self.storage objectForKey:@"cardIdx"]];
            break;
        }
            
        // specific set
        case kFacetSet: {
            [searchClauses addObject:@"sets.pk = ?"];
            [searchParams addObject:[self.storage objectForKey:@"setPk"]];
            break;
        }
            
        // title text
        case kFacetTitleText: {
            NSString *text = [[self class] sanitizedSearchString:[self.storage objectForKey:@"titleText"]];
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
            
        // oracle text
        case kFacetOracleText: {            
            /*
            NSString *text = [self.storage objectForKey:@"oracleText"];
            if (text != nil && text.length >= kMinimumSearchCharacters) {
                NSArray *nameHashes = [self findNameHashesByOracleText:text];
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
            */
            break;
        }

        default:
            break;
    }
}

// ----------------------------------------------------------------------------

- (id) initWithCategory:(FacetCategory *) facetCategory {
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

- (NSString *) description {
    if (self.category.identifier == kFacetTitleText) {
        return [self.storage objectForKey:@"titleText"];
    }
    return @"Unknown Search Criteria";
}

// ----------------------------------------------------------------------------

@end
