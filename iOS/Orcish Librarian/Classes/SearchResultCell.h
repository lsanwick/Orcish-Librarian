//
//  SearchResultCell.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/1/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Card;

@interface SearchResultCell : UITableViewCell

+ (CGFloat) height;

@property (nonatomic, strong) Card *card;
@property (nonatomic, assign) BOOL hidesCount;

@end
