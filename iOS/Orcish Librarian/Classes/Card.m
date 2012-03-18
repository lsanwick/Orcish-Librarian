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

#define kMinimumSearchCharacters 3
#define kMaxSearchNames 5

@implementation Card

@synthesize pk;
@synthesize name;
@synthesize gathererId;
@synthesize setPk;
@synthesize setName;
@synthesize collectorNumber;
@synthesize rarity;
@synthesize manaCost;
@synthesize typeLine;
@synthesize oracleText;
@synthesize power;
@synthesize toughness;
@synthesize loyalty;
@synthesize versionCount;

// ----------------------------------------------------------------------------

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.setName];
}

// ----------------------------------------------------------------------------

+ (Card *) cardForResultSet:(FMResultSet *)rs {
    Card *card = [[Card alloc] init];
    card.pk = [rs stringForColumn:@"pk"];
    card.name = [rs stringForColumn:@"name"];
    card.gathererId = [rs stringForColumn:@"gatherer_id"];
    card.setPk = [rs stringForColumn:@"set_pk"];
    card.setName = [rs stringForColumn:@"set_name"];
    card.collectorNumber = [rs stringForColumn:@"collector_number"];
    card.rarity = [rs stringForColumn:@"rarity"];
    card.manaCost = [rs stringForColumn:@"mana_cost"];
    card.typeLine = [rs stringForColumn:@"type_line"];
    card.oracleText = [rs stringForColumn:@"oracle_text"];
    card.power = [rs stringForColumn:@"power"];
    card.toughness = [rs stringForColumn:@"toughness"];
    card.loyalty = [rs stringForColumn:@"loyalty"];
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
    
    // NAME
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
        [orderClauses addObject:@"set_name ASC"];
    }
    
    // construct & execute the SQL query
    NSString *sql = [NSString stringWithFormat:
        @"SELECT    cards.*, "
        @"          sets.name AS set_name "
        @"FROM      cards, sets "
        @"WHERE     cards.set_pk = sets.pk "
        @"AND      (%@) "
        @"ORDER BY  %@",                     
        [searchClauses componentsJoinedByString:@" AND "],
        [orderClauses componentsJoinedByString:@", "]];
    FMResultSet *rs = [gAppDelegate.db executeQuery:sql withArgumentsInArray:
        [searchParams arrayByAddingObjectsFromArray:orderParams]];
    NSMutableArray *cards = [NSMutableArray array];
    while ([rs next]) {
        [cards addObject:[self cardForResultSet:rs]];
    }
    return cards;
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

@end
