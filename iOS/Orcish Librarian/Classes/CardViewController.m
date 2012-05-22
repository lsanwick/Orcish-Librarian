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
#import "CardSequence.h"
#import "AppDelegate.h"

#define kPageCount 3

typedef void (^block_t)(void);

@class Card;

@interface CardViewController ()

- (void) scrollAllViewsToTop;

@property (nonatomic, assign) NSUInteger layoutIndex;
@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, assign) BOOL hasAppearedBefore;

@end

@implementation CardViewController 

@synthesize sequence;
@synthesize position;
@synthesize layoutIndex;
@synthesize pages;
@synthesize scrollView;
@synthesize hasAppearedBefore;
@synthesize pagingButton;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
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

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.scrollView.scrollsToTop = NO;
}

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollAllViewsToTop];
    self.scrollView.scrollsToTop = YES;
    if (!self.hasAppearedBefore) {
        self.hasAppearedBefore = YES;
        [gAppDelegate trackScreen:@"/CardView"];    
        CGFloat width = self.scrollView.frame.size.width;
        CGFloat height = self.scrollView.frame.size.height;    
        NSUInteger pageCount = MIN(kPageCount, self.sequence.count);
        self.layoutIndex = MIN(self.position, (self.sequence.count - pageCount));
        for (int i = 0; i < pageCount; i++) {
            CardView *page = [self.pages objectAtIndex:i];
            [self.scrollView addSubview:page];
            page.frame = CGRectMake(width * i, 0, width, height);
            page.card = [self.sequence cardAtPosition:self.layoutIndex+i];
        }
        self.scrollView.contentSize = CGSizeMake(width * MIN(self.sequence.count, kPageCount), height);
        NSUInteger pageOffset = position - self.layoutIndex;
        [self.scrollView scrollRectToVisible:CGRectMake(width * pageOffset, 0, width, height) animated:NO];
        [self scrollViewDidEndDecelerating:self.scrollView];
        self.pagingButton.hidden = self.sequence.count <= 1;
    }
}

// ----------------------------------------------------------------------------

- (IBAction) pagingButtonTapped:(id)sender {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGFloat pageHeight = self.scrollView.frame.size.height;
    CGFloat x = self.scrollView.contentOffset.x + (self.pagingButton.selectedSegmentIndex == 0 ? -pageWidth : pageWidth);
    [UIView animateWithDuration:0.3
        animations:^{            
            [self.scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, pageHeight) animated:NO];
        } 
        completion:^(BOOL finished){
            [self scrollViewDidEndDecelerating:self.scrollView];
        }];        
}

// ----------------------------------------------------------------------------

- (void) updatePagingButtons {
    self.navigationItem.title = [[self.sequence cardAtPosition:self.position] displayName];
    [self.pagingButton setEnabled:((self.position + 1) < self.sequence.count) forSegmentAtIndex:1];
    [self.pagingButton setEnabled:(self.position > 0) forSegmentAtIndex:0];    
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
    lastPage.card = [self.sequence cardAtPosition:self.layoutIndex];
}

// ----------------------------------------------------------------------------

- (void) shiftLeft {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGFloat pageHeight = self.scrollView.frame.size.height;
    for (int i = 1; i < kPageCount; i++) {
        CardView *page = [self.pages objectAtIndex:i];
        page.frame = CGRectMake((i-1) * pageWidth, 0, pageWidth, pageHeight);
    }
    CardView *firstPage = [self.pages objectAtIndex:0];
    firstPage.frame = CGRectMake((kPageCount-1) * pageWidth, 0, pageWidth, pageHeight);
    [self.pages removeObjectAtIndex:0];
    [pages addObject:firstPage];
    firstPage.card = [sequence cardAtPosition:self.layoutIndex+kPageCount];
    self.layoutIndex = self.layoutIndex + 1;
}

// ----------------------------------------------------------------------------

- (void) scrollAllViewsToTop {
    for (int i = 0; i < kPageCount; i++) {
        [[[self.pages objectAtIndex:i] scrollView] setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

// ----------------------------------------------------------------------------
//  UIScrollViewDelegate
// ----------------------------------------------------------------------------

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [gAppDelegate hideMenu];
}

// ----------------------------------------------------------------------------

- (void) scrollViewDidEndDecelerating:(UIScrollView *)view {
    NSUInteger pageWidth = view.frame.size.width;
    NSUInteger pageHeight = view.frame.size.height;
    NSUInteger index = view.contentOffset.x / pageWidth;
    NSUInteger middlePage = floor(kPageCount / 2.0);    
    if (index > middlePage && self.layoutIndex < (self.sequence.count - kPageCount)) {
        [self shiftLeft];
        [self scrollAllViewsToTop];
        [self.scrollView scrollRectToVisible:CGRectMake(pageWidth * (index - 1), 0 , pageWidth, pageHeight) animated:NO];        
    } else if (index < middlePage && self.layoutIndex > 0) {
        [self shiftRight];
        [self scrollAllViewsToTop];
        [self.scrollView scrollRectToVisible:CGRectMake(pageWidth * (index + 1), 0 , pageWidth, pageHeight) animated:NO];
    }
    self.position = (view.contentOffset.x / pageWidth) + layoutIndex;
    [self updatePagingButtons];    
}

// ----------------------------------------------------------------------------

@end
