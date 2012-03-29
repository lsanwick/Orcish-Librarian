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
#import "OrcishViewController.h"
#import "CardViewController.h"
#import "MenuController.h"
#import "Utility.h"


@interface OrcishRootController () {
    CardViewController *queuedCardViewController;
}
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

// ----------------------------------------------------------------------------

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.controllerStack = [[NSMutableArray alloc] init];
        queuedCardViewController = [[CardViewController alloc] initWithNibName:nil bundle:nil];
        [queuedCardViewController view];
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

- (CardViewController *) dequeueCardViewController {
    CardViewController *previous = queuedCardViewController;
    queuedCardViewController = [[CardViewController alloc] initWithNibName:nil bundle:nil];
    [queuedCardViewController view];
    return previous;
}

// ----------------------------------------------------------------------------

- (void) pushViewController:(OrcishViewController *)controller animated:(BOOL)animated {
    [controller willPush:animated];
    [self.controllerStack addObject:controller];
    controller.view.frame = CGRectMake(self.contentView.frame.size.width, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
    [self.contentView addSubview:controller.view];
    [self updateMenuButton];
    [UIView animateWithDuration:(animated ? 0.2 : 0.0)
        animations:^{
            controller.view.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
        }
        completion:^(BOOL finished){
            [controller pushed];
        }];
}

// ----------------------------------------------------------------------------

- (void) popViewControllerAnimated:(BOOL)animated {    
    OrcishViewController *controller = [self.controllerStack lastObject];
    [controller willPop:animated];
    [self.controllerStack removeLastObject];
    [self updateMenuButton];
    [UIView animateWithDuration:(animated ? 0.2 : 0.0)
        animations:^{
            controller.view.frame = CGRectMake(self.contentView.frame.size.width, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
        } 
        completion:^(BOOL finished){
            [controller.view removeFromSuperview];
            [controller popped];
        }];        
}

// ----------------------------------------------------------------------------

- (void) setViewController:(OrcishViewController *)controller animated:(BOOL)animated {
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [controller willPush:animated];
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
            [controller pushed];
        }];
}

// ----------------------------------------------------------------------------

- (OrcishViewController *) topController {
    return self.controllerStack.lastObject;
}

// ----------------------------------------------------------------------------

@end
