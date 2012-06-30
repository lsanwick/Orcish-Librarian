//
//  SearchFacetCategory.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/26/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "FacetCategory.h"

@interface FacetCategory () 

@property (nonatomic, assign) FacetCategoryIdentifier identifier;
@property (nonatomic, strong) NSString *description;

@end

@implementation FacetCategory

@synthesize identifier;
@synthesize description;

// ----------------------------------------------------------------------------

+ (FacetCategory *) titleText {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetTitleText;
        singleton.description = @"Title";
    });
    return singleton;
}

// ----------------------------------------------------------------------------

+ (FacetCategory *) card {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetCard;
        singleton.description = @"Primary Key";
    });
    return singleton;
}

// ----------------------------------------------------------------------------

+ (FacetCategory *) index {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetIndex;
        singleton.description = @"Index";
    });
    return singleton;
    
}

// ----------------------------------------------------------------------------

+ (FacetCategory *) oracleText {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetOracleText;
        singleton.description = @"Card Text";
    });
    return singleton;

}

// ----------------------------------------------------------------------------

+ (FacetCategory *) rarity {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetRarity;
        singleton.description = @"Rarity";
    });
    return singleton;

}

// ----------------------------------------------------------------------------

+ (FacetCategory *) set {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetSet;
        singleton.description = @"Set";
    });
    return singleton;

}

// ----------------------------------------------------------------------------

+ (FacetCategory *) block {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetBlock;
        singleton.description = @"Block";
    });
    return singleton;

}

// ----------------------------------------------------------------------------

+ (FacetCategory *) format {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetFormat;
        singleton.description = @"Format";
    });
    return singleton;

}

// ----------------------------------------------------------------------------

+ (FacetCategory *) colors {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetColors;
        singleton.description = @"Colors";
    });
    return singleton;

}

// ----------------------------------------------------------------------------

+ (FacetCategory *) type {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetType;
        singleton.description = @"Type";
    });
    return singleton;
}

// ----------------------------------------------------------------------------

+ (FacetCategory *) convertedManaCost {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetCMC;
        singleton.description = @"Converted Mana Cost";
    });
    return singleton;
}

// ----------------------------------------------------------------------------

+ (FacetCategory *) power {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetPower;
        singleton.description = @"Power";
    });
    return singleton;
}

// ----------------------------------------------------------------------------

+ (FacetCategory *) toughness {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetToughness;
        singleton.description = @"Toughness";
    });
    return singleton;
}

// ----------------------------------------------------------------------------

+ (FacetCategory *) loyalty {
    static FacetCategory *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[FacetCategory alloc] init];
        singleton.identifier = kFacetLoyalty;
        singleton.description = @"Loyalty";
    });
    return singleton;
}

// ----------------------------------------------------------------------------

@end
