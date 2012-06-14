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
#import "SearchFacet.h"
#import "NSNull+Wrap.h"

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
@synthesize setDisplayName;
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
    card.setDisplayName = [NSNull wrapNil:[rs stringForColumn:@"set_display_name"]];
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
    return [self findCards:[NSArray arrayWithObject:[SearchFacet facetWithTitleText:text]]];
}

// ----------------------------------------------------------------------------

+ (CardSequence *) findCardsBySet:(NSUInteger)setPk {
    return [self findCards:[NSArray arrayWithObject:[SearchFacet facetWithSet:setPk]]];
}

// ----------------------------------------------------------------------------

+ (CardSequence *) findCards:(NSArray *)facets {
    
    NSMutableArray *searchClauses = [NSMutableArray array];
    NSMutableArray *searchParams = [NSMutableArray array];
    NSMutableArray *orderClauses = [NSMutableArray array];
    NSMutableArray *orderParams = [NSMutableArray array];
    
    for (SearchFacet *facet in facets) {
        [facet updateSearchClauses:searchClauses withParams:searchParams andOrderClauses:orderClauses withParams:orderParams];
    }
    
    if (searchClauses.count == 0) {
        // don't bother running the search if there's no search criteria
        return [[StaticCardSequence alloc] initWithCards:[NSArray array]];
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
        @"          sets.display_name AS set_display_name, "
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
        @"          sets.display_name AS set_display_name, "
        @"          sets.tcg AS tcg_set_name "
        @"FROM      cards, sets "
        @"WHERE     cards.set_pk = sets.pk "
        @"AND       cards.pk IN (%@) "
        @"ORDER BY  cards.search_name ASC, sets.idx DESC, cards.art_index ASC",
        primaryKeys];
    return [[QueryCardSequence alloc] initWithQuery:sql argumentsInArray:nil collapse:NO];
}

// ----------------------------------------------------------------------------

+ (Card *) findCardByPk:(NSUInteger)pk {
    CardSequence *sequence = [Card findCards:[NSArray arrayWithObject:[SearchFacet facetWithCard:pk]]];
    return (sequence.count) > 0 ? [sequence cardAtPosition:0] : nil;
}

// ----------------------------------------------------------------------------

+ (Card *) findRandomCard {
    __block NSUInteger idx;
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:@"SELECT MAX(idx) FROM cards"];
        [rs next];
        idx = (arc4random() % [rs longForColumnIndex:0]) + 1;        
    });
    CardSequence *sequence = [Card findCards:[NSArray arrayWithObject:[SearchFacet facetWithIndex:idx]]];
    return (sequence.count) > 0 ? [sequence cardAtPosition:0] : nil;
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
        self.setDisplayName, @"setDisplayName",
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
            @"SELECT   sets.pk AS set_pk, "
            @"         sets.name AS set_name, "
            @"         sets.display_name AS set_display_name "
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
                [rs stringForColumn:@"set_display_name"], @"setDisplayName",
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
