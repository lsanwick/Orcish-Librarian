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

@interface CardViewController : OrcishViewController <UIScrollViewDelegate, UIWebViewDelegate> 

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *pagingButton;

- (IBAction) pagingButtonTapped:(id)sender;

@property (strong, nonatomic) CardSequence *sequence;
@property (assign, nonatomic) NSUInteger position;

@end
