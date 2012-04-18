//
//  CardView.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 4/17/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Card;

@interface CardView : UIWebView <UIWebViewDelegate>

@property (nonatomic, strong) Card *card;

@end
