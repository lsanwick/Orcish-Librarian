//
//  CardViewController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/13/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "CardViewController.h"
#import "Card.h"
#import "CardView.h"
#import "AppDelegate.h"

#define kPageCount 3

typedef void (^block_t)(void);

@class Card;

@interface CardViewController ()

@property (nonatomic, assign) NSUInteger layoutIndex;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation CardViewController 

@synthesize cards;
@synthesize position;
@synthesize layoutIndex;
@synthesize pages;
@synthesize scrollView;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Linen-Background"]];
    scrollView.bounces = YES;    
    NSURL *cardURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HTML/Card.html"]];    
    self.pages = [NSMutableArray arrayWithCapacity:kPageCount];
    for (int i = 0; i < kPageCount; i++) {
        CardView *page = [[CardView alloc] initWithFrame:scrollView.frame];
        [self.pages addObject:page];
        page.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Linen-Background"]];        
        [page loadRequest:[NSURLRequest requestWithURL:cardURL]];
    }
    self.layoutIndex = 0;
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;    
    NSUInteger pageCount = MIN(kPageCount, self.cards.count);
    self.layoutIndex = MIN(self.position, (self.cards.count - pageCount));
    for (int i = 0; i < pageCount; i++) {
        CardView *page = [self.pages objectAtIndex:i];
        [self.scrollView addSubview:page];
        page.frame = CGRectMake(width * i, 0, width, height);
        page.card = [self.cards objectAtIndex:self.layoutIndex+i];
    }
    self.scrollView.contentSize = CGSizeMake(width * MIN(self.cards.count, kPageCount), height);
    NSUInteger pageOffset = position - self.layoutIndex;
    [self.scrollView scrollRectToVisible:CGRectMake(width * pageOffset, 0, width, height) animated:NO];
    [self scrollViewDidEndDecelerating:self.scrollView];
}

// ----------------------------------------------------------------------------

- (void) viewWillDisappear:(BOOL)animated {
    position = 0;
    for (int i = 0; i < kPageCount; i++) {
        CardView *page = [self.pages objectAtIndex:i];
        [page removeFromSuperview];
    }
}

// ----------------------------------------------------------------------------

- (void) shiftRight {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGFloat pageHeight = self.scrollView.frame.size.height;
    for (int i = 0; i < (kPageCount-1); i++) {
        CardView *page = [self.pages objectAtIndex:i];
        page.frame = CGRectMake((i+1) * pageWidth, 0, pageWidth, pageHeight);
    }
    CardView *lastPage = [self.pages objectAtIndex:(kPageCount-1)];
    lastPage.frame = CGRectMake(0, 0, pageWidth, pageHeight);
    [self.pages removeLastObject];
    [self.pages insertObject:lastPage atIndex:0];
    self.layoutIndex = self.layoutIndex - 1;
    lastPage.card = [self.cards objectAtIndex:self.layoutIndex];
}

// ----------------------------------------------------------------------------

- (void) shiftLeft {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGFloat pageHeight = self.scrollView.frame.size.height;
    for (int i = 1; i < kPageCount; i++) {
        CardView *page = [self.pages objectAtIndex:i];
        page.frame = CGRectMake((i-1) * pageWidth, 0, pageWidth, pageHeight);
    }
    CardView *firstPage = [self.pages  objectAtIndex:0];
    firstPage.frame = CGRectMake((kPageCount-1) * pageWidth, 0, pageWidth, pageHeight);
    [self.pages removeObjectAtIndex:0];
    [pages addObject:firstPage];
    firstPage.card = [cards objectAtIndex:self.layoutIndex+kPageCount];
    self.layoutIndex = self.layoutIndex + 1;
}

// ----------------------------------------------------------------------------
//  UIScrollViewDelegate
// ----------------------------------------------------------------------------

- (void) scrollViewDidEndDecelerating:(UIScrollView *)view {
    NSUInteger pageWidth = view.frame.size.width;
    NSUInteger pageHeight = view.frame.size.height;
    NSUInteger index = view.contentOffset.x / pageWidth;
    NSUInteger middlePage = floor(kPageCount / 2.0);
    if (index > middlePage && self.layoutIndex < (self.cards.count - kPageCount)) {
        [self shiftLeft];
        [self.scrollView scrollRectToVisible:CGRectMake(pageWidth * (index - 1), 0 , pageWidth, pageHeight) animated:NO];
    } else if (index < middlePage && self.layoutIndex > 0) {
        [self shiftRight];
        [self.scrollView scrollRectToVisible:CGRectMake(pageWidth * (index + 1), 0 , pageWidth, pageHeight) animated:NO];
    }
    for (int i = 0; i < kPageCount; i++) {
        [[[self.pages objectAtIndex:i] scrollView] setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

// ----------------------------------------------------------------------------

@end
