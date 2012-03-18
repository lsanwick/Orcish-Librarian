//
//  OrcishViewController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 11/6/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrcishViewController : UIViewController

- (void) willPop:(BOOL)animated;
- (void) popped;
- (void) willPush:(BOOL)animated;
- (void) pushed;

@end
