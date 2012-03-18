//
//  CardViewController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/13/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishViewController.h"

@class CardSequence;

@interface CardViewController : OrcishViewController <UIScrollViewDelegate> {
    NSMutableArray *pages;
    UIScrollView *scrollView;
    NSUInteger layoutIndex;
}

- (void) loadCard:(NSUInteger)index forView:(UIWebView *)view;

@property (strong, nonatomic) NSArray *cards;
@property (assign, nonatomic) NSUInteger position;

@end
