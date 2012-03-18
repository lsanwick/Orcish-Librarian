//
//  SearchCriteria.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/24/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "SearchCriteria.h"
#import "RegexKitLite.h"

@implementation SearchCriteria

@synthesize nameText;
@synthesize exactNameMatch;
@synthesize oracleText;
@synthesize types;
@synthesize colors;
@synthesize exactColorMatch;
@synthesize convertedManaCost;
@synthesize power;
@synthesize toughness;
@synthesize sets;

// ----------------------------------------------------------------------------

+ (NSString *) sanitizedSearchString:(NSString *)text {
    text = [text uppercaseString]; // all upper-case
    text = [text stringByReplacingOccurrencesOfRegex:@"\\(.*?\\)" withString:@""]; // remove parenthetical text
    text = [text stringByReplacingOccurrencesOfRegex:@"[^A-Z]" withString:@""]; // remove non-alphanumeric characters
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // trim whitespace
    return text;
}

// ----------------------------------------------------------------------------

- (void) setNameText:(NSString *)text {
    nameText = [[self class] sanitizedSearchString:text];
}

// ----------------------------------------------------------------------------

@end
