//
//  CardViewController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/13/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CardSequence;

@interface CardViewController : UIViewController <UIScrollViewDelegate, UIWebViewDelegate> 

@property (strong, nonatomic) CardSequence *sequence;
@property (assign, nonatomic) NSUInteger position;

@end
