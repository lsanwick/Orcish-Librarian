//
//  SearchResultCell.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/1/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "SearchResultCell.h"
#import "PriceManager.h"
#import "Card.h"

#define kCellPadding        10.0f
#define kCellSpacing        3.0f
#define kNameFontSize       17.0f
#define kPriceFontSize      12.0f
#define kSetFontSize        12.0f
#define kPriceWidth         50.0f
#define kNameHeight         32.0f
#define kSetHeight          32.0f


@interface SearchResultCell () {
    UILabel *priceLabelLow;
    UILabel *priceLabelMid;
    UILabel *priceLabelHigh;
    UILabel *nameLabel;
    UILabel *setLabel;
}

+ (UIFont *) nameLabelFont;
+ (UIFont *) setLabelFont;
+ (UIFont *) priceLabelFont;
+ (CGFloat) nameLabelHeight;
+ (CGFloat) setLabelHeight;
+ (CGFloat) priceLabelHeight;
+ (CGFloat) priceLabelWidthForText:(NSString *)text;

@end


@implementation SearchResultCell

@synthesize card;

// ----------------------------------------------------------------------------

+ (UIFont *) nameLabelFont {
    static UIFont *font = nil;
    if (!font) {
        font = [UIFont boldSystemFontOfSize:kNameFontSize]; 
    }
    return font;
}

// ----------------------------------------------------------------------------

+ (UIFont *) setLabelFont {
    static UIFont *font = nil;
    if (!font) {
        font = [UIFont systemFontOfSize:kSetFontSize];
    }
    return font;
}

// ----------------------------------------------------------------------------

+ (UIFont *) priceLabelFont {
    static UIFont *font = nil;
    if (!font) {
        font = [UIFont systemFontOfSize:kPriceFontSize];
    }
    return font;
}

// ----------------------------------------------------------------------------

+ (CGFloat) nameLabelHeight {
    static CGFloat height = 0.0;
    if (height < 0.1) {
        height = ([@"ABC" sizeWithFont:[self nameLabelFont] forWidth:100.0 lineBreakMode:UILineBreakModeTailTruncation]).height;
    }
    return height;
}

// ----------------------------------------------------------------------------

+ (CGFloat) setLabelHeight {
    static CGFloat height = 0.0;
    if (height < 0.1) {
        height = ([@"ABC" sizeWithFont:[self setLabelFont] forWidth:100.0 lineBreakMode:UILineBreakModeTailTruncation]).height;
    }
    return height;
}

// ----------------------------------------------------------------------------

+ (CGFloat) priceLabelHeight {
    static CGFloat height = 0.0;
    if (height < 0.1) {
        height = ([@"ABC" sizeWithFont:[self priceLabelFont] forWidth:100.0 lineBreakMode:UILineBreakModeTailTruncation]).height;
    }
    return height;
}

// ----------------------------------------------------------------------------

+ (CGFloat) priceLabelWidthForText:(NSString *)text {
    CGFloat width = ([text sizeWithFont:[self priceLabelFont] forWidth:500.0 lineBreakMode:UILineBreakModeTailTruncation]).width;
    return width + 5.0;
}

// ----------------------------------------------------------------------------

+ (CGFloat) height {
    return MAX(
        // combined height of the left-hand rows
        kCellPadding + 
        [self nameLabelHeight] + 
        kCellSpacing + 
        [self setLabelHeight] + 
        kCellPadding,
        // combined height of the right-hand rows
        [self priceLabelHeight] * 3.0);
}

// ----------------------------------------------------------------------------

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        priceLabelLow = [[UILabel alloc] init];
        priceLabelMid = [[UILabel alloc] init];
        priceLabelHigh = [[UILabel alloc] init];
        nameLabel = [[UILabel alloc] init];
        setLabel = [[UILabel alloc] init];
        priceLabelLow.font = [[self class] priceLabelFont];
        priceLabelMid.font = [[self class] priceLabelFont];
        priceLabelHigh.font = [[self class] priceLabelFont];
        nameLabel.font = [[self class] nameLabelFont];
        setLabel.font = [[self class] setLabelFont];
        priceLabelLow.textAlignment = UITextAlignmentRight;
        priceLabelMid.textAlignment = UITextAlignmentRight;
        priceLabelHigh.textAlignment = UITextAlignmentRight;
        [self addSubview:priceLabelLow];
        [self addSubview:priceLabelMid];
        [self addSubview:priceLabelHigh];
        [self addSubview:nameLabel];
        [self addSubview:setLabel];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

// ----------------------------------------------------------------------------

- (void) setCard:(Card *)newCard {
    card = newCard;
    NSArray *otherEditions = card.otherEditions;
    NSDictionary *price = [[PriceManager shared] priceForCard:card];  
    priceLabelLow.text = price ? [NSString stringWithFormat:@"L: $%@", [price objectForKey:@"low"]] : @"";
    priceLabelMid.text = price ? [NSString stringWithFormat:@"M: $%@", [price objectForKey:@"average"]] : @"";
    priceLabelHigh.text = price ? [NSString stringWithFormat:@"H: $%@", [price objectForKey:@"high"]] : @"";
    nameLabel.text = card.name;    
    if (otherEditions.count > 0) {
        setLabel.text = [NSString stringWithFormat:@"%@ (%d more)", card.setName, otherEditions.count];
    } else {
        setLabel.text = card.setName;
    }
}

// ----------------------------------------------------------------------------

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    CGFloat nameHeight = [[self class] nameLabelHeight];
    CGFloat setHeight = [[self class] setLabelHeight];
    CGFloat priceHeight = [[self class] priceLabelHeight];
    CGFloat priceY = (bounds.size.height - (priceHeight * 3.0)) / 2.0;
    CGFloat priceWidth = [[self class] priceLabelWidthForText:priceLabelHigh.text];
    nameLabel.frame = CGRectMake(kCellPadding, kCellPadding, bounds.size.width - (kCellSpacing + kCellPadding + priceWidth + kCellPadding), nameHeight);
    setLabel.frame = CGRectMake(kCellPadding, kCellPadding + nameHeight + kCellSpacing, bounds.size.width - (kCellSpacing + kCellPadding + priceWidth + kCellPadding), setHeight);
    priceLabelLow.frame = CGRectMake(bounds.size.width - (kCellPadding + priceWidth), priceY, priceWidth, priceHeight);
    priceLabelMid.frame = CGRectMake(bounds.size.width - (kCellPadding + priceWidth), priceY + priceHeight, priceWidth, priceHeight);
    priceLabelHigh.frame = CGRectMake(bounds.size.width - (kCellPadding + priceWidth), priceY + (priceHeight * 2.0), priceWidth, priceHeight);
    NSLog(@"%@", NSStringFromCGRect(nameLabel.frame));
    NSLog(@"%@", NSStringFromCGRect(setLabel.frame));
    NSLog(@"%@", NSStringFromCGRect(priceLabelLow.frame));
    NSLog(@"%@", NSStringFromCGRect(priceLabelMid.frame));
    NSLog(@"%@", NSStringFromCGRect(priceLabelHigh.frame));
}

// ----------------------------------------------------------------------------

@end
