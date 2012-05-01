//
//  PriceVendorCell.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/30/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "PriceVendorCell.h"

#define kCellPadding        10.0f
#define kCellSpacing        3.0f
#define kNameFontSize       17.0f
#define kPriceFontSize      20.0f
#define kConditionFontSize  12.0f
#define kPriceWidth         50.0f
#define kNameHeight         32.0f
#define kConditionHeight    32.0f


@interface PriceVendorCell ()

+ (UIFont *) nameLabelFont;
+ (UIFont *) conditionLabelFont;
+ (UIFont *) priceLabelFont;
+ (CGFloat) nameLabelHeight;
+ (CGFloat) conditionLabelHeight;
+ (CGFloat) priceLabelHeight;
+ (CGFloat) priceLabelWidthForText:(NSString *)text;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *conditionLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@end


@implementation PriceVendorCell

@synthesize nameLabel;
@synthesize conditionLabel;
@synthesize priceLabel;
@synthesize vendor;

// ----------------------------------------------------------------------------

+ (UIFont *) nameLabelFont {
    static UIFont *font = nil;
    if (!font) {
        font = [UIFont boldSystemFontOfSize:kNameFontSize]; 
    }
    return font;
}

// ----------------------------------------------------------------------------

+ (UIFont *) conditionLabelFont {
    static UIFont *font = nil;
    if (!font) {
        font = [UIFont systemFontOfSize:kConditionFontSize];
    }
    return font;
}

// ----------------------------------------------------------------------------

+ (UIFont *) priceLabelFont {
    static UIFont *font = nil;
    if (!font) {
        font = [UIFont boldSystemFontOfSize:kPriceFontSize];
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

+ (CGFloat) conditionLabelHeight {
    static CGFloat height = 0.0;
    if (height < 0.1) {
        height = ([@"ABC" sizeWithFont:[self conditionLabelFont] forWidth:100.0 lineBreakMode:UILineBreakModeTailTruncation]).height;
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
        [self conditionLabelHeight] + 
        kCellPadding,
        // combined height of the right-hand rows
        [self priceLabelHeight]);
}

// ----------------------------------------------------------------------------

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.priceLabel = [[UILabel alloc] init];
        self.nameLabel = [[UILabel alloc] init];
        self.conditionLabel = [[UILabel alloc] init];
        self.priceLabel.font = [[self class] priceLabelFont];
        self.nameLabel.font = [[self class] nameLabelFont];
        self.conditionLabel.font = [[self class] conditionLabelFont];
        self.priceLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:self.priceLabel];
        [self addSubview:self.nameLabel];
        [self addSubview:self.conditionLabel];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

// ----------------------------------------------------------------------------

- (void) setVendor:(NSDictionary *)theVendor {
    vendor = theVendor;
    self.nameLabel.text = [theVendor objectForKey:@"storeName"];
    self.conditionLabel.text = [theVendor objectForKey:@"condition"];
    self.priceLabel.text = [NSString stringWithFormat:@"$%@", [theVendor objectForKey:@"price"]];
}

// ----------------------------------------------------------------------------

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    CGFloat nameHeight = [[self class] nameLabelHeight];
    CGFloat conditionHeight = [[self class] conditionLabelHeight];
    CGFloat priceHeight = [[self class] priceLabelHeight];
    CGFloat priceWidth = [[self class] priceLabelWidthForText:self.priceLabel.text];
    self.nameLabel.frame = CGRectMake(kCellPadding, kCellPadding, bounds.size.width - (kCellSpacing + kCellPadding + priceWidth + kCellPadding), nameHeight);
    self.conditionLabel.frame = CGRectMake(kCellPadding, kCellPadding + nameHeight + kCellSpacing, bounds.size.width - (kCellSpacing + kCellPadding + priceWidth + kCellPadding), conditionHeight);
    self.priceLabel.frame = CGRectMake(bounds.size.width - (kCellPadding + priceWidth), (bounds.size.height - priceHeight) / 2.0, priceWidth, priceHeight);
}

// ----------------------------------------------------------------------------

@end
