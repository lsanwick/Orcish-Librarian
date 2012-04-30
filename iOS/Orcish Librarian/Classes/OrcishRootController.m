//
//  OrcishRootController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/19/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "OrcishRootController.h"
#import "CardViewController.h"
#import "MenuController.h"
#import "Utility.h"


#define kMaxControllerStackDepth 10


@interface OrcishRootController () 

@property (strong, nonatomic) NSMutableArray *controllerStack;
@property (assign, nonatomic) BOOL menuIsVisible;
@property (strong, nonatomic) NSMutableArray *modalControllerStack;

@end


@implementation OrcishRootController

@synthesize menuView;
@synthesize menuController;
@synthesize dropShadowView;
@synthesize slideView;
@synthesize contentView;
@synthesize navigationBar;
@synthesize navigationItem;
@synthesize menuButton;
@synthesize backButton;
@synthesize controllerStack;
@synthesize menuIsVisible;
@synthesize modalControllerStack;

// ----------------------------------------------------------------------------

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.controllerStack = [[NSMutableArray alloc] init];
        self.modalControllerStack = [[NSMutableArray alloc] init];
    }
    return self;
}

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    menuButton.image = [UIImage imageNamed:@"Menu-Button"];
    [menuController viewDidLoad];
    dropShadowView.layer.masksToBounds = NO;
    dropShadowView.layer.cornerRadius = 0.0;
    dropShadowView.layer.shadowOffset = CGSizeMake(-5, 0);
    dropShadowView.layer.shadowRadius = 5;
    dropShadowView.layer.shadowOpacity = 0.5;
    dropShadowView.layer.shouldRasterize = YES; 
}

// ----------------------------------------------------------------------------

- (void) hideMenu {
    self.menuIsVisible = NO;
    CGRect menuFrame = self.menuView.frame;
    CGRect slideFrame = self.slideView.frame;
    menuFrame.origin.x = -menuFrame.size.width;
    slideFrame.origin.x = 0.0;
    [UIView animateWithDuration:0.2
        animations:^{
            self.slideView.frame = slideFrame; 
        }];
}

// ----------------------------------------------------------------------------

- (void) showMenu {
    [gAppDelegate hideKeyboard];
    self.menuIsVisible = YES;
    CGRect menuFrame = self.menuView.frame;
    CGRect slideFrame = self.slideView.frame;
    menuFrame.origin.x = 0.0;
    slideFrame.origin.x = menuFrame.size.width;
    [UIView animateWithDuration:0.2
        animations:^{
            self.slideView.frame = slideFrame;
        }];
}

// ----------------------------------------------------------------------------

- (IBAction) menuButtonTapped:(id)sender {
    if (self.controllerStack.count > 1) {
        [self popViewControllerAnimated:YES];
    } else if (self.menuIsVisible) {
        [self hideMenu];
    } else {
        [self showMenu];
    }
}

// ----------------------------------------------------------------------------

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ----------------------------------------------------------------------------

- (void) updateMenuButton {
    if (self.controllerStack.count > 1) {
        self.menuButton.image = [UIImage imageNamed:@"Back-Button"];
    } else {
        self.menuButton.image = [UIImage imageNamed:@"Menu-Button"];
    }
}

// ----------------------------------------------------------------------------

- (void) pushViewController:(UIViewController *)controller animated:(BOOL)animated {
    [self.controllerStack addObject:controller];
    controller.view.frame = CGRectMake(self.contentView.frame.size.width, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
    [self.contentView addSubview:controller.view];
    [self updateMenuButton];
    [UIView animateWithDuration:(animated ? 0.2 : 0.0)
        animations:^{
            controller.view.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
        }
        completion:^(BOOL finished){

        }];
    if (self.controllerStack.count > kMaxControllerStackDepth) {
        [[[self.controllerStack objectAtIndex:0] view] removeFromSuperview];
        [self.controllerStack removeObjectAtIndex:0];
    }
}

// ----------------------------------------------------------------------------

- (void) popViewControllerAnimated:(BOOL)animated {    
    UIViewController *controller = [self.controllerStack lastObject];
    [self.controllerStack removeLastObject];
    [self updateMenuButton];
    [UIView animateWithDuration:(animated ? 0.2 : 0.0)
        animations:^{
            controller.view.frame = CGRectMake(self.contentView.frame.size.width, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
        } 
        completion:^(BOOL finished){
            [controller.view removeFromSuperview];
        }];        
}

// ----------------------------------------------------------------------------

- (void) setViewController:(UIViewController *)controller animated:(BOOL)animated {
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [self.controllerStack removeAllObjects];
    [self.controllerStack addObject:controller];
    controller.view.alpha = 0.0;
    controller.view.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:controller.view];
    [self updateMenuButton];
    [UIView animateWithDuration:(animated ? 0.2 : 0.0) 
        animations:^{
            controller.view.alpha = 1.0;
        }
        completion:^(BOOL animated){

        }];
}

// ----------------------------------------------------------------------------

- (void) presentModalViewController:(UIViewController *)controller animated:(BOOL)animated {
    [self.modalControllerStack addObject:controller];
    controller.view.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);    
    [self.view addSubview:controller.view];
    [UIView animateWithDuration:(animated ? 0.4 : 0.0)
        animations:^{
            controller.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);    
        }
        completion:^(BOOL finished){

        }];
}

// ----------------------------------------------------------------------------

- (void) dismissModalViewControllerAnimated:(BOOL)animated {
    UIViewController *controller = [self.modalControllerStack lastObject];
    [self.modalControllerStack removeLastObject];
    [UIView animateWithDuration:(animated ? 0.4 : 0.0)
    animations:^{
        controller.view.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);    
    } 
    completion:^(BOOL finished){
        [controller.view removeFromSuperview];
    }];           
}

// ----------------------------------------------------------------------------

- (UIViewController *) topController {
    return self.controllerStack.lastObject;
}

// ----------------------------------------------------------------------------

@end
