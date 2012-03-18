//
//  CardViewController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/13/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "CardViewController.h"

#define kPageCount 3

@class Card;

@implementation CardViewController

@synthesize cards;
@synthesize position;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Linen-Background"]];
    scrollView.bounces = YES;    
    NSURL *cardURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HTML/Card.html"]];    
    pages = [NSMutableArray arrayWithCapacity:kPageCount];
    for (int i = 0; i < kPageCount; i++) {
        UIWebView *page = [[UIWebView alloc] initWithFrame:scrollView.frame];
        [pages addObject:page];
        page.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Linen-Background"]];        
        [page loadRequest:[NSURLRequest requestWithURL:cardURL]];
    }
    layoutIndex = 0;
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    int pageCount = MIN(kPageCount, cards.count);
    layoutIndex = MIN(position, cards.count - pageCount);
    for (int i = 0; i < pageCount; i++) {
        UIWebView *page = [pages objectAtIndex:i];
        [scrollView addSubview:page];
        page.frame = CGRectMake(width * i, 0, width, height);
        [self loadCard:(layoutIndex+i) forView:page];
    }
    scrollView.contentSize = CGSizeMake(width * MIN(cards.count, kPageCount), height);
    NSUInteger pageOffset = position - layoutIndex;
    [scrollView scrollRectToVisible:CGRectMake(width * pageOffset, 0, width, height) animated:NO];
    [self scrollViewDidEndDecelerating:scrollView];
}

// ----------------------------------------------------------------------------

- (void) viewWillDisappear:(BOOL)animated {
    position = 0;
    for (int i = 0; i < kPageCount; i++) {
        UIWebView *page = [pages objectAtIndex:i];
        [page removeFromSuperview];
    }
}

// ----------------------------------------------------------------------------

- (void) loadCard:(NSUInteger)index forView:(UIWebView *)view {
    Card *card = [cards objectAtIndex:index];
    [view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:
        @""]];
}

// ----------------------------------------------------------------------------

- (void) shiftRight {
    CGFloat pageWidth = scrollView.frame.size.width;
    CGFloat pageHeight = scrollView.frame.size.height;
    for (int i = 0; i < (kPageCount-1); i++) {
        UIWebView *page = [pages objectAtIndex:i];
        page.frame = CGRectMake((i+1) * pageWidth, 0, pageWidth, pageHeight);
    }
    UIWebView *lastPage = [pages objectAtIndex:(kPageCount-1)];
    lastPage.frame = CGRectMake(0, 0, pageWidth, pageHeight);
    [pages removeLastObject];
    [pages insertObject:lastPage atIndex:0];
    layoutIndex = layoutIndex - 1;
    [self loadCard:layoutIndex forView:lastPage];
}

// ----------------------------------------------------------------------------

- (void) shiftLeft {
    CGFloat pageWidth = scrollView.frame.size.width;
    CGFloat pageHeight = scrollView.frame.size.height;
    for (int i = 1; i < kPageCount; i++) {
        UIWebView *page = [pages objectAtIndex:i];
        page.frame = CGRectMake((i-1) * pageWidth, 0, pageWidth, pageHeight);
    }
    UIWebView *firstPage = [pages  objectAtIndex:0];
    firstPage.frame = CGRectMake((kPageCount-1) * pageWidth, 0, pageWidth, pageHeight);
    [pages removeObjectAtIndex:0];
    [pages addObject:firstPage];
    [self loadCard:(layoutIndex+kPageCount) forView:firstPage];
    layoutIndex = layoutIndex + 1;
}

// ----------------------------------------------------------------------------
//  UIScrollViewDelegate
// ----------------------------------------------------------------------------

- (void) scrollViewDidEndDecelerating:(UIScrollView *)view {
    NSUInteger pageWidth = view.frame.size.width;
    NSUInteger pageHeight = view.frame.size.height;
    NSUInteger index = view.contentOffset.x / pageWidth;
    NSUInteger middlePage = floor(kPageCount / 2.0);
    if (index > middlePage && layoutIndex < (cards.count - kPageCount)) {
        [self shiftLeft];
        [scrollView scrollRectToVisible:CGRectMake(pageWidth * (index - 1), 0 , pageWidth, pageHeight) animated:NO];
    } else if (index < middlePage && layoutIndex > 0) {
        [self shiftRight];
        [scrollView scrollRectToVisible:CGRectMake(pageWidth * (index + 1), 0 , pageWidth, pageHeight) animated:NO];
    }
    for (int i = 0; i < kPageCount; i++) {
        [[[pages objectAtIndex:i] scrollView] setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

// ----------------------------------------------------------------------------

@end
