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
#import "DataManager.h"
#import "StaticCardSequence.h"
#import "QueryCardSequence.h"
#import "Card.h"
#import "SearchCriteria.h"
#import "NSNull+Wrap.h"

#define kMinimumSearchCharacters 3
#define kMaxSearchNames 5

@interface Card ()

@end

@implementation Card

@synthesize pk;
@synthesize name;
@synthesize displayName;
@synthesize searchName;
@synthesize nameHash;
@synthesize tcgName;
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
@synthesize oracleText;
@synthesize power;
@synthesize toughness;
@synthesize loyalty;

// ----------------------------------------------------------------------------

+ (Card *) cardForResultSet:(FMResultSet *)rs {
    Card *card = [NSNull wrapNil:[[Card alloc] init]];
    card.pk = (NSUInteger) [rs longForColumn:@"pk"];
    card.searchName = [NSNull wrapNil:[rs stringForColumn:@"search_name"]];
    card.nameHash = (NSUInteger) [rs longForColumn:@"name_hash"];
    card.name = [NSNull wrapNil:[rs stringForColumn:@"name"]];
    card.displayName = [NSNull wrapNil:[rs stringForColumn:@"display_name"]];
    card.tcgName = [NSNull wrapNil:[rs stringForColumn:@"tcg"]];
    card.gathererId = (NSUInteger) [rs longForColumn:@"gatherer_id"];
    card.setPk = (NSUInteger) [rs longForColumn:@"set_pk"];
    card.setName = [NSNull wrapNil:[rs stringForColumn:@"set_name"]];
    card.tcgSetName = [NSNull wrapNil:[rs stringForColumn:@"tcg_set_name"]];
    card.collectorNumber = [NSNull wrapNil:[rs stringForColumn:@"collector_number"]];
    card.artist = [NSNull wrapNil:[rs stringForColumn:@"artist"]];
    card.artIndex = [NSNull wrapNil:[rs stringForColumn:@"art_index"]];
    card.rarity = [NSNull wrapNil:[rs stringForColumn:@"rarity"]];
    card.manaCost = [NSNull wrapNil:[rs stringForColumn:@"mana_cost"]];
    card.typeLine = [NSNull wrapNil:[rs stringForColumn:@"type_line"]];
    card.oracleText = [NSNull wrapNil:[rs stringForColumn:@"oracle_text"]];
    card.power = [NSNull wrapNil:[rs stringForColumn:@"power"]];
    card.toughness = [NSNull wrapNil:[rs stringForColumn:@"toughness"]];
    card.loyalty = [NSNull wrapNil:[rs stringForColumn:@"loyalty"]];
    return card;
}

// ----------------------------------------------------------------------------

+ (CardSequence *) findCardsByTitleText:(NSString *)text {
    SearchCriteria *criteria = [[SearchCriteria alloc] init];
    criteria.nameText = text;
    return [self findCards:criteria];
}

// ----------------------------------------------------------------------------

+ (CardSequence *) findCardsBySet:(NSUInteger)setPk {
    SearchCriteria *criteria = [[SearchCriteria alloc] init];
    criteria.sets = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:setPk]];
    return [self findCards:criteria];
}

// ----------------------------------------------------------------------------

+ (CardSequence *) findCards:(SearchCriteria *)criteria {
    
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
            [searchClauses addObject:[NSString stringWithFormat:@"cards.name_hash IN (%@)", [marks componentsJoinedByString:@", "]]];
            [searchParams addObjectsFromArray:nameHashes];
            [orderClauses addObject:[NSString stringWithFormat:@"(SUBSTR(cards.search_name, 0, %d) = ?) DESC", criteria.nameText.length + 1]];
            [orderParams addObject:criteria.nameText];
        }
    }
    
    // set
    if (criteria.sets != nil && criteria.sets.count > 0) {
        NSMutableArray *marks = [NSMutableArray arrayWithCapacity:criteria.sets.count];
        for (int i = 0; i < criteria.sets.count; i++) {
            [marks addObject:@"?"];
        }
        [searchClauses addObject:[NSString stringWithFormat:@"cards.set_pk IN (%@)", [marks componentsJoinedByString:@", "]]];
        [searchParams addObjectsFromArray:criteria.sets];
    }
    
    if (searchClauses.count == 0) {
        // don't bother running the search if there's no search criteria
        return [NSArray array];
    } else {
        // otherwise, the default search order is appended to the end of whatever
        // order order criteria we've got set up.
        [orderClauses addObject:@"search_name ASC"];
        [orderClauses addObject:@"set_idx DESC"];
        [orderClauses addObject:@"art_index ASC"];
    }
    
    // construct & execute the SQL query
    NSString *sql = [NSString stringWithFormat:
        @"SELECT    cards.*, "
        @"          sets.name AS set_name, "
        @"          sets.pk AS set_pk, "
        @"          sets.idx AS set_idx, "
        @"          sets.tcg AS tcg_set_name "
        @"FROM      cards, sets "
        @"WHERE     cards.set_pk = sets.pk "
        @"AND      (%@) "
        @"ORDER BY  %@",                     
        [searchClauses componentsJoinedByString:@" AND "],
        [orderClauses componentsJoinedByString:@", "]];
        
    return [[QueryCardSequence alloc] initWithQuery:sql argumentsInArray:[searchParams arrayByAddingObjectsFromArray:orderParams]];
}

// ----------------------------------------------------------------------------

+ (CardSequence *) findBookmarkedCards {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *bookmarks = [defaults objectForKey:@"bookmarks"];
    NSString *primaryKeys = [[bookmarks allKeys] componentsJoinedByString:@","];    
    NSString *sql = [NSString stringWithFormat:
        @"SELECT    cards.*, "
        @"          sets.name AS set_name, "
        @"          sets.tcg AS tcg_set_name "
        @"FROM      cards, sets "
        @"WHERE     cards.set_pk = sets.pk "
        @"AND       cards.pk IN (%@) ",
        primaryKeys];
    return [[QueryCardSequence alloc] initWithQuery:sql];
}

// ----------------------------------------------------------------------------

+ (Card *) findCardByIdx:(NSString *)idx {
    NSString *sql = 
        @"SELECT    cards.*, "
        @"          sets.name AS set_name, "
        @"          sets.tcg AS tcg_set_name "
        @"FROM      cards, sets "
        @"WHERE     cards.set_pk = sets.pk "
        @"AND       cards.idx = ? ";
    __block Card *result = nil;
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:sql withArgumentsInArray:
            [NSArray arrayWithObject:idx]];
        result = [rs next] ? [self cardForResultSet:rs] : nil;
    });
    return result;
}

// ----------------------------------------------------------------------------

+ (Card *) findCardByPk:(NSUInteger)pk {
    NSString *sql = 
        @"SELECT    cards.*, "
        @"          sets.name AS set_name, "
        @"          sets.tcg AS tcg_set_name "
        @"FROM      cards, sets "
        @"WHERE     cards.set_pk = sets.pk "
        @"AND       cards.pk = ? ";
    __block Card *card = nil;
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:sql withArgumentsInArray:
            [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:pk]]];        
        card = [rs next] ? [self cardForResultSet:rs] : nil;
    });
    return card;
}

// ----------------------------------------------------------------------------

+ (Card *) findRandomCard {
    __block NSNumber *idx = nil;
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:@"SELECT MAX(idx) FROM cards"];
        [rs next];
        idx = [NSNumber numberWithInt:(arc4random() % [rs intForColumnIndex:0]) + 1];        
    });
    return [self findCardByIdx:[idx stringValue]];
}

// ----------------------------------------------------------------------------

+ (NSArray *) findNameHashesByText:(NSString *)text {
    NSMutableArray *hashes = [NSMutableArray array];
    if (text.length < kMinimumSearchCharacters) { return [NSArray array]; }
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
    return [NSString stringWithFormat:@"%@ (%@)", self.displayName, self.setName];
}

// ----------------------------------------------------------------------------

- (BOOL) isBookmarked {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *bookmarks = [defaults objectForKey:@"bookmarks"];
    return ([bookmarks objectForKey:[[NSNumber numberWithUnsignedInteger:self.pk] stringValue]] != nil);
}

// ----------------------------------------------------------------------------

- (void) setIsBookmarked:(BOOL)bookmarked {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSSet *existing = [defaults objectForKey:@"bookmarks"];
    NSMutableDictionary *bookmarks = existing ? [existing mutableCopy] : [NSMutableDictionary dictionary];
    if (bookmarked) {
        [bookmarks setObject:[NSNumber numberWithBool:YES] forKey:[[NSNumber numberWithUnsignedInteger:self.pk] stringValue]];
    } else {
        [bookmarks removeObjectForKey:[[NSNumber numberWithUnsignedInteger:self.pk] stringValue]];
    }
    [defaults setObject:bookmarks forKey:@"bookmarks"];
    [defaults synchronize];
}

// ----------------------------------------------------------------------------

- (NSString *) toJSON {
    NSError *error;
    NSDictionary *source = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedInteger:self.pk], @"pk",
        [NSNumber numberWithUnsignedInteger:self.gathererId], @"gathererId",
        self.name, @"name",
        self.displayName, @"displayName",
        self.setName, @"setName",
        self.tcgSetName, @"tcgSetName",
        self.artist, @"artist",
        self.artIndex, @"artIndex",
        self.manaCost, @"manaCost",
        self.oracleText, @"oracleText",
        self.rarity, @"rarity",
        self.typeLine, @"typeLine",
        self.power, @"power",
        self.toughness, @"toughness",
        self.loyalty, @"loyalty",
        self.otherEditions, @"otherEditions",
        self.otherParts, @"otherParts",
        self.artVariants, @"artVariants",
        [NSNumber numberWithBool:self.isBookmarked], @"isBookmarked",
        nil];
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:source 
        options:0 error:&error] encoding:NSUTF8StringEncoding];
}

// ----------------------------------------------------------------------------

- (NSArray *) otherParts {
    NSMutableArray *cards = [NSMutableArray array];
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:
            @"SELECT   cards.* "
            @"FROM     cards, sets "
            @"WHERE    cards.set_pk = ? "
            @"AND      cards.set_pk = sets.pk "
            @"AND      cards.collector_number == ? "
            @"AND      cards.collector_number != '' "
            @"AND      cards.pk != ? "
            @"AND      cards.rarity = ? "
            @"AND      cards.rarity != 'L' "
            @"AND      sets.name != 'Planeshift' ",
            [NSNumber numberWithUnsignedInteger:self.setPk],
            self.collectorNumber,
            [NSNumber numberWithUnsignedInteger:self.pk],
            self.rarity];
        while([rs next]) {
            [cards addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [rs stringForColumn:@"display_name"], @"displayName",
                [rs stringForColumn:@"pk"], @"pk", 
                nil]];
        }
    });
    return cards;
}

// ----------------------------------------------------------------------------

- (NSArray *) otherEditions {
    NSMutableArray *cards = [NSMutableArray array];
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:
            @"SELECT   sets.pk AS set_pk, sets.name AS set_name "
            @"FROM     cards, sets "
            @"WHERE    cards.set_pk = sets.pk "
            @"AND      cards.name_hash = ? "
            @"AND      cards.pk != ? "
            @"AND     (cards.art_index = '' OR cards.art_index = 1) "
            @"AND      sets.pk != ? " 
            @"ORDER BY sets.idx DESC",
            [NSNumber numberWithUnsignedInteger:self.nameHash],
            [NSNumber numberWithUnsignedInteger:self.pk],
            [NSNumber numberWithUnsignedInteger:self.setPk]];
        while([rs next]) {
            [cards addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [rs stringForColumn:@"set_name"], @"setName",
                [rs stringForColumn:@"set_pk"], @"setPk", 
                nil]];
        }
    });
    return cards;
}

// ----------------------------------------------------------------------------

- (NSArray *) artVariants {
    NSMutableArray *cards = [NSMutableArray array];
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:
            @"SELECT   cards.* "
            @"FROM     cards "
            @"WHERE    cards.set_pk = ? "
            @"AND      cards.name_hash == ? "
            @"ORDER BY cards.art_index ASC",
            [NSNumber numberWithUnsignedInteger:self.setPk],
            [NSNumber numberWithUnsignedInteger:self.nameHash]];
        while([rs next]) {
            [cards addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [rs stringForColumn:@"artist"], @"artist",
                [rs stringForColumn:@"art_index"], @"artIndex",
                [rs stringForColumn:@"pk"], @"pk", 
                nil]];
        }
    });
    return cards;    
}

// ----------------------------------------------------------------------------

@end
