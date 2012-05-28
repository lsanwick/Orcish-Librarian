//
//  OrcishRootController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/19/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuController;
@class CardViewController;

@interface OrcishRootController : UIViewController

@property (strong, nonatomic) NSMutableArray *controllerStack;
@property (strong, nonatomic) IBOutlet UITableView *menuView;
@property (strong, nonatomic) IBOutlet MenuController *menuController;
@property (strong, nonatomic) IBOutlet UIView *dropShadow;
@property (strong, nonatomic) IBOutlet UIView *slideView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (readonly, nonatomic) UIViewController *topController;
@property (assign, nonatomic) BOOL menuIsVisible;

- (void) pushViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void) popViewControllerAnimated:(BOOL)animated;
- (void) setViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void) hideMenu;
- (void) showMenu;

@end
