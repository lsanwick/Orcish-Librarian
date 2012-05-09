//
//  CardSet.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/9/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "CardSet.h"
#import "Card.h"
#import "AppDelegate.h"

@implementation CardSet

@synthesize name;
@synthesize pk;

// ----------------------------------------------------------------------------

+ (NSArray *) findAll {
    NSMutableArray *sets = [NSMutableArray array];
    NSString *sql = 
        @"SELECT    sets.* "
        @"FROM      sets "
        @"ORDER BY  pk DESC";
    FMResultSet *rs = [gAppDelegate.db executeQuery:sql];
    while([rs next]) {
        CardSet *set = [[CardSet alloc] init];
        set.pk = [rs stringForColumn:@"pk"];
        set.name = [rs stringForColumn:@"name"];
        [sets addObject:set];
    } 
    return sets;
}

// ----------------------------------------------------------------------------

- (NSArray *) cards {
    return [Card findCardsBySet:self.pk];
}

// ----------------------------------------------------------------------------

@end
