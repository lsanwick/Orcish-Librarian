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
#import "DataManager.h"

@implementation CardSet

@synthesize name;
@synthesize pk;

// ----------------------------------------------------------------------------

+ (NSArray *) findStandardSets {
    NSMutableArray *sets = [NSMutableArray array];
    NSString *sql = 
        @"SELECT    sets.* "
        @"FROM      sets "
        @"WHERE     format = 1 "
        @"ORDER BY  idx DESC ";
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:sql];
        while([rs next]) {
            CardSet *set = [[CardSet alloc] init];
            set.pk = (NSUInteger) [rs longForColumn:@"pk"];
            set.name = [rs stringForColumn:@"name"];
            [sets addObject:set];
        } 
    });
    return sets;
}

// ----------------------------------------------------------------------------

+ (NSArray *) findAll {
    NSMutableArray *sets = [NSMutableArray array];
    NSString *sql = 
        @"SELECT    sets.* "
        @"FROM      sets "
        @"ORDER BY  name ASC";
    dispatch_sync(gAppDelegate.dataQueue, ^{
        FMResultSet *rs = [gDataManager.db executeQuery:sql];
        while([rs next]) {
            CardSet *set = [[CardSet alloc] init];
            set.pk = (NSUInteger) [rs longForColumn:@"pk"];
            set.name = [rs stringForColumn:@"name"];
            [sets addObject:set];
        } 
    });
    return sets;
}

// ----------------------------------------------------------------------------

- (NSArray *) cards {
    return [Card findCardsBySet:self.pk];
}

// ----------------------------------------------------------------------------

@end
