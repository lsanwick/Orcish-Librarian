//
//  Card.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/12/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "RegexKitLite.h"
#import "FMDatabase.h"
#import "AppDelegate.h"
#import "Card.h"
#import "SearchCriteria.h"
#import "NSNull+Wrap.h"

#define kMinimumSearchCharacters 3
#define kMaxSearchNames 5

@implementation Card

@synthesize pk;
@synthesize name;
@synthesize searchName;
@synthesize nameHash;
@synthesize gathererId;
@synthesize setPk;
@synthesize setName;
@synthesize tcgSetName;
@synthesize collectorNumber;
@synthesize artist;
@synthesize artIndex;
@synthesize rarity;
@synthesize manaCost;
@synthesize typeLine;
@synthesize isToken;
@synthesize oracleText;
@synthesize power;
@synthesize toughness;
@synthesize loyalty;
@synthesize versionCount;

// ----------------------------------------------------------------------------

+ (Card *) cardForResultSet:(FMResultSet *)rs {
    Card *card = [NSNull wrapNil:[[Card alloc] init]];
    card.pk = [NSNull wrapNil:[rs stringForColumn:@"pk"]];
    card.searchName = [NSNull wrapNil:[rs stringForColumn:@"search_name"]];
    card.nameHash = [NSNull wrapNil:[rs stringForColumn:@"name_hash"]];
    card.name = [NSNull wrapNil:[rs stringForColumn:@"name"]];
    card.gathererId = [NSNull wrapNil:[rs stringForColumn:@"gatherer_id"]];
    card.setPk = [NSNull wrapNil:[rs stringForColumn:@"set_pk"]];
    card.setName = [NSNull wrapNil:[rs stringForColumn:@"set_name"]];
    card.tcgSetName = [NSNull wrapNil:[rs stringForColumn:@"tcg_set_name"]];
    card.collectorNumber = [NSNull wrapNil:[rs stringForColumn:@"collector_number"]];
    card.artist = [NSNull wrapNil:[rs stringForColumn:@"artist"]];
    card.artIndex = [NSNull wrapNil:[rs stringForColumn:@"art_index"]];
    card.rarity = [NSNull wrapNil:[rs stringForColumn:@"rarity"]];
    card.manaCost = [NSNull wrapNil:[rs stringForColumn:@"mana_cost"]];
    card.typeLine = [NSNull wrapNil:[rs stringForColumn:@"type_line"]];
    card.isToken = [rs boolForColumn:@"is_token"];
    card.oracleText = [NSNull wrapNil:[rs stringForColumn:@"oracle_text"]];
    card.power = [NSNull wrapNil:[rs stringForColumn:@"power"]];
    card.toughness = [NSNull wrapNil:[rs stringForColumn:@"toughness"]];
    card.loyalty = [NSNull wrapNil:[rs stringForColumn:@"loyalty"]];
    card.versionCount = [rs intForColumn:@"version_count"];
    return card;
}

// ----------------------------------------------------------------------------

+ (NSArray *) findCardsByTitleText:(NSString *)text {
    SearchCriteria *criteria = [[SearchCriteria alloc] init];
    criteria.nameText = text;
    return [self findCards:criteria];
}

// ----------------------------------------------------------------------------

+ (NSArray *) findCards:(SearchCriteria *)criteria {
    
    NSMutableArray *searchClauses = [NSMutableArray array];
    NSMutableArray *searchParams = [NSMutableArray array];
    NSMutableArray *orderClauses = [NSMutableArray array];
    NSMutableArray *orderParams = [NSMutableArray array];
    
    // name
    if (criteria.nameText != nil && criteria.nameText.length >= kMinimumSearchCharacters) {
        NSArray *nameHashes = [self findNameHashesByText:criteria.nameText];
        if (nameHashes.count > 0) {
            NSMutableArray *marks = [NSMutableArray arrayWithCapacity:nameHashes.count];
            for (int i = 0; i < nameHashes.count; i++) {
                [marks addObject:@"?"];
            }
            [searchClauses addObject:[NSString stringWithFormat:@"name_hash IN (%@)", [marks componentsJoinedByString:@", "]]];
            [searchParams addObjectsFromArray:nameHashes];
            [orderClauses addObject:[NSString stringWithFormat:@"(SUBSTR(search_name, 0, %d) = ?) DESC", criteria.nameText.length + 1]];
            [orderParams addObject:criteria.nameText];
        }
    }
    
    if (searchClauses.count == 0) {
        // don't bother running the search if there's no search criteria
        return [NSArray array];
    } else {
        // otherwise, the default search order is appended to the end of whatever
        // order order criteria we've got set up.
        [orderClauses addObject:@"search_name ASC"];
        [orderClauses addObject:@"set_pk DESC"];
    }
    
    // construct & execute the SQL query
    NSString *sql = [NSString stringWithFormat:
        @"SELECT    cards.*, "
        @"          sets.name AS set_name, "
        @"          sets.pk AS set_pk, "
        @"          sets.tcg AS tcg_set_name "
        @"FROM      cards, sets "
        @"WHERE     cards.set_pk = sets.pk "
        @"AND      (%@) "
        @"ORDER BY  %@",                     
        [searchClauses componentsJoinedByString:@" AND "],
        [orderClauses componentsJoinedByString:@", "]];
    FMResultSet *rs = [gAppDelegate.db executeQuery:sql withArgumentsInArray:[searchParams arrayByAddingObjectsFromArray:orderParams]];
    NSMutableArray *cards = [NSMutableArray array];
    while ([rs next]) {
        [cards addObject:[self cardForResultSet:rs]];
    }
    return cards;
}

// ----------------------------------------------------------------------------

+ (Card *) findCardByPk:(NSString *)pk {
    NSString *sql = 
        @"SELECT    cards.*, "
        @"          sets.name AS set_name, "
        @"          sets.tcg AS tcg_set_name "
        @"FROM      cards, sets "
        @"WHERE     cards.set_pk = sets.pk "
        @"AND       cards.pk = ? ";
    FMResultSet *rs = [gAppDelegate.db executeQuery:sql withArgumentsInArray:
        [NSArray arrayWithObject:pk]];        
    return [rs next] ? [self cardForResultSet:rs] : nil;
}

// ----------------------------------------------------------------------------

+ (NSArray *) findNameHashesByText:(NSString *)text {
    if (text.length < kMinimumSearchCharacters) { return [NSArray array]; }
    NSMutableArray *searchNames = [NSMutableArray array];
    NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSData *blob = gAppDelegate.searchNames;
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
        [searchNames addObject:[[NSString alloc] initWithBytes:&blobText[pkStart] length:(pkEnd-pkStart) encoding:NSUTF8StringEncoding]];
    }
    return searchNames;
}

// ----------------------------------------------------------------------------

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.setName];
}

// ----------------------------------------------------------------------------

- (NSArray *) artVariants {
    NSMutableArray *cards = [NSMutableArray array];
    FMResultSet *rs = [gAppDelegate.db executeQuery:
        @"SELECT   cards.* "
        @"FROM     cards "
        @"WHERE    cards.set_pk = ? "
        @"AND      cards.name_hash == ? "
        @"ORDER BY cards.art_index ASC",
        self.setPk,
        self.nameHash];
    while([rs next]) {
        [cards addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            [rs stringForColumn:@"artist"], @"artist",
            [rs stringForColumn:@"art_index"], @"artIndex",
            [rs stringForColumn:@"pk"], @"pk", 
            nil]];
    }                          
    return cards;    
}

// ----------------------------------------------------------------------------

- (NSArray *) otherParts {
    NSMutableArray *cards = [NSMutableArray array];
    FMResultSet *rs = [gAppDelegate.db executeQuery:
        @"SELECT   cards.* "
        @"FROM     cards "
        @"WHERE    cards.set_pk = ? "
        @"AND      cards.collector_number == ? "
        @"AND      cards.collector_number != '' "
        @"AND      cards.is_token == 0 "
        @"AND      cards.pk != ? ",
        self.setPk,
        self.collectorNumber,
        self.pk];
    while([rs next]) {
        [cards addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            [rs stringForColumn:@"name"], @"name",
            [rs stringForColumn:@"pk"], @"pk", 
            nil]];
    }                          
    return cards;
}
 
// ----------------------------------------------------------------------------

- (NSArray *) otherEditions {
    NSMutableArray *cards = [NSMutableArray array];
    FMResultSet *rs = [gAppDelegate.db executeQuery:
        @"SELECT   cards.*, "
        @"         sets.name AS set_name "
        @"FROM     cards, sets "
        @"WHERE    cards.set_pk = sets.pk "
        @"AND      cards.name_hash = ? "
        @"AND      cards.pk != ? "
        @"AND      sets.pk != ? ",
        self.nameHash,
        self.pk,
        self.setPk];
    while([rs next]) {
        [cards addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            [rs stringForColumn:@"set_name"], @"setName",
            [rs stringForColumn:@"pk"], @"pk", 
            nil]];
    }                          
    return cards;
}

// ----------------------------------------------------------------------------

- (NSString *) toJSON {
    NSError *error;
    NSDictionary *source = [NSDictionary dictionaryWithObjectsAndKeys:
        self.pk,                                @"pk",
        self.gathererId,                        @"gathererId",
        self.name,                              @"name",
        self.setName,                           @"setName",
        self.tcgSetName,                        @"tcgSetName",
        self.collectorNumber,                   @"collectorNumber",
        self.artist,                            @"artist",
        self.artIndex,                          @"artIndex",
        self.manaCost,                          @"manaCost",
        self.oracleText,                        @"oracleText",
        self.rarity,                            @"rarity",
        self.typeLine,                          @"typeLine",
        self.power,                             @"power",
        self.toughness,                         @"toughness",
        self.loyalty,                           @"loyalty",
        self.otherEditions,                     @"otherEditions",
        self.otherParts,                        @"otherParts",
        self.artVariants,                       @"artVariants",
        [NSNumber numberWithBool:self.isToken], @"isToken",
        nil];
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:source 
        options:0 error:&error] encoding:NSUTF8StringEncoding];
}

// ----------------------------------------------------------------------------

@end
