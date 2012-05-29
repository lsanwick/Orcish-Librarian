//
//  QueryCardSequence.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/28/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "QueryCardSequence.h"
#import "Card.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "FMDatabase.h"

@interface QueryCardSequence ()

@property (nonatomic, strong) NSString *sql;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) NSArray *cards;
@property (nonatomic, assign) BOOL hydrated;

@end

@implementation QueryCardSequence

@synthesize sql;
@synthesize arguments;
@synthesize cards;
@synthesize hydrated;

// ----------------------------------------------------------------------------

- (id) initWithQuery:(NSString *)theSql {
    return [self initWithQuery:theSql argumentsInArray:[NSArray array]];
}

// ----------------------------------------------------------------------------

- (id) initWithQuery:(NSString *)theSql argumentsInArray:(NSArray *)theArguments {
    if (self = [super init]) {
        self.sql = theSql;
        self.arguments = [theArguments copy];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (Card *) cardAtPosition:(NSUInteger)position {    
    if (!self.hydrated) {
        [self hydrate];
    }
    return [self.cards objectAtIndex:position];
}

// ----------------------------------------------------------------------------

- (NSUInteger) count {
    if (!self.hydrated) {
        [self hydrate];
    }
    return self.cards.count;
}

// ----------------------------------------------------------------------------

- (void) hydrate {
    if (!self.hydrated) {
        NSMutableArray *results = [NSMutableArray array];
        dispatch_sync(gAppDelegate.dataQueue, ^{
            FMResultSet *rs = [gDataManager.db executeQuery:self.sql withArgumentsInArray:self.arguments];
            while ([rs next]) {
                [results addObject:[Card cardForResultSet:rs]];
            }
        });
        self.cards = [results copy];
        NSLog(@"Hydrating (%d cards)", self.cards.count);
        self.hydrated = YES;
    }
}

// ----------------------------------------------------------------------------

- (void) dehydrate {
    if (self.hydrated) {
        NSLog(@"Dehydrating (%d cards)", self.cards.count);
        self.cards = nil;
        self.hydrated = NO;
    }
}

// ----------------------------------------------------------------------------

@end
