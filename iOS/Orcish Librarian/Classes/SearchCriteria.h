//
//  SearchCriteria.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/24/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchCriteria : NSObject

@property (strong, nonatomic) NSString *nameText;
@property (assign, nonatomic) BOOL exactNameMatch;
@property (strong, nonatomic) NSString *oracleText;
@property (strong, nonatomic) NSArray *types;
@property (strong, nonatomic) NSArray *colors;
@property (assign, nonatomic) BOOL exactColorMatch;
@property (strong, nonatomic) NSNumber *convertedManaCost;
@property (strong, nonatomic) NSNumber *power;
@property (strong, nonatomic) NSNumber *toughness;
@property (strong, nonatomic) NSArray *sets;

@end
