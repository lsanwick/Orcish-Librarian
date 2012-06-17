//
//  CardViewController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/13/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrcishSequenceController.h"

@class CardSequence;

@interface CardViewController : OrcishSequenceController <UIScrollViewDelegate, UIWebViewDelegate> 

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *pagingButton;

- (IBAction) pagingButtonTapped:(id)sender;

@property (assign, nonatomic) NSUInteger position;

@end
