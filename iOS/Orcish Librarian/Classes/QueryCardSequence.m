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
@property (nonatomic, assign) BOOL collapse;
@property (nonatomic, strong) NSArray *cards;
@property (nonatomic, assign) BOOL hydrated;

@end

@implementation QueryCardSequence

@synthesize sql;
@synthesize arguments;
@synthesize collapse;
@synthesize cards;
@synthesize hydrated;

// ----------------------------------------------------------------------------

- (id) initWithQuery:(NSString *)theSql {
    return [self initWithQuery:theSql argumentsInArray:nil collapse:YES];
}

// ----------------------------------------------------------------------------

- (id) initWithQuery:(NSString *)theSql argumentsInArray:(NSArray *)theArguments {
    return [self initWithQuery:theSql argumentsInArray:theArguments collapse:YES];
}

// ----------------------------------------------------------------------------

- (id) initWithQuery:(NSString *)theSql argumentsInArray:(NSArray *)theArguments collapse:(BOOL)shouldCollapse {
    if (self = [super init]) {
        self.collapse = shouldCollapse; 
        self.sql = theSql;
        self.arguments = theArguments ? [theArguments copy] : [NSArray array];
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
        NSMutableSet *names;
        if (self.collapse) {
            names = [NSMutableSet set];
        }
        NSMutableArray *results = [NSMutableArray array];
        dispatch_sync(gAppDelegate.dataQueue, ^{
            FMResultSet *rs = [gDataManager.db executeQuery:self.sql withArgumentsInArray:self.arguments];
            while ([rs next]) {
                Card *card = [Card cardForResultSet:rs];
                if (!self.collapse || ![names containsObject:card.name]) {
                    [results addObject:card];
                    if (self.collapse) {
                        [names addObject:card.name];
                    }
                } 
            }
        });
        self.cards = [results copy];
        self.hydrated = YES;
    }
}

// ----------------------------------------------------------------------------

- (void) dehydrate {
    if (self.hydrated) {
        self.cards = nil;
        self.hydrated = NO;
    }
}

// ----------------------------------------------------------------------------

@end
