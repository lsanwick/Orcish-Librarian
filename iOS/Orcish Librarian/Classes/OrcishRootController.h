//
//  OrcishRootController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/19/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuController;
@class OrcishViewController;

@interface OrcishRootController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *menuView;
@property (strong, nonatomic) IBOutlet MenuController *menuController;
@property (strong, nonatomic) IBOutlet UIView *dropShadowView;
@property (strong, nonatomic) IBOutlet UIView *slideView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) NSMutableArray *controllerStack;
@property (assign, nonatomic) BOOL menuIsVisible;
@property (readonly, nonatomic) OrcishViewController *topController;

- (void) pushViewController:(OrcishViewController *)controller animated:(BOOL)animated;
- (void) popViewControllerAnimated:(BOOL)animated;
- (void) setViewController:(OrcishViewController *)controller animated:(BOOL)animated;

- (void) hideMenu;
- (void) showMenu;

- (IBAction) menuButtonTapped:(id)sender;

@end
