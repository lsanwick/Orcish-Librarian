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
#define kMenuAnimatePeriod 0.25
#define kControllerAnimatePeriod 0.3
#define kModalAnimatePeriod 0.4


@interface OrcishRootController () 

@property (strong, nonatomic) NSMutableArray *modalControllerStack;

@end


@implementation OrcishRootController

@synthesize menuView;
@synthesize menuController;
@synthesize dropShadow;
@synthesize slideView;
@synthesize contentView;
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
    [menuController viewDidLoad];
    self.dropShadow.layer.masksToBounds = NO;
    self.dropShadow.layer.cornerRadius = 0.0;
    self.dropShadow.layer.shadowOffset = CGSizeMake(-5, 0);
    self.dropShadow.layer.shadowRadius = 5;
    self.dropShadow.layer.shadowOpacity = 0.5;
    self.dropShadow.layer.shouldRasterize = YES; 
}

// ----------------------------------------------------------------------------

- (void) hideMenu {
    self.menuIsVisible = NO;
    CGRect menuFrame = self.menuView.frame;
    CGRect slideFrame = self.slideView.frame;
    menuFrame.origin.x = -menuFrame.size.width;
    slideFrame.origin.x = 0.0;
    [UIView animateWithDuration:kMenuAnimatePeriod
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
    [UIView animateWithDuration:kMenuAnimatePeriod
        animations:^{
            self.slideView.frame = slideFrame;
        }];
}

// ----------------------------------------------------------------------------

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

// ----------------------------------------------------------------------------

- (void) pushViewController:(UIViewController *)controller animated:(BOOL)animated {
    [gAppDelegate hideMenu];
    [gAppDelegate hideKeyboard];
    [self.controllerStack.lastObject viewWillDisappear:animated];
    [self.controllerStack addObject:controller];
    controller.view.frame = CGRectMake(self.contentView.frame.size.width, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
    controller.view.alpha = 0.0;
    [self.contentView addSubview:controller.view];
    [UIView animateWithDuration:(animated ? kControllerAnimatePeriod : 0.0)
        animations:^{            
            controller.view.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
            controller.view.alpha = 1.0;
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
    UIViewController *controller = self.controllerStack.lastObject;
    [self.controllerStack removeLastObject];
    [self.controllerStack.lastObject viewWillAppear:animated];
    [UIView animateWithDuration:(animated ? kControllerAnimatePeriod : 0.0)
        animations:^{            
            controller.view.frame = CGRectMake(self.contentView.frame.size.width, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
            controller.view.alpha = 0.0;
        } 
        completion:^(BOOL finished){
            [controller.view removeFromSuperview];            
            [self.controllerStack.lastObject viewDidAppear:animated];
        }];        
}

// ----------------------------------------------------------------------------

- (void) setViewController:(UIViewController *)controller animated:(BOOL)animated {
    [gAppDelegate hideMenu];
    [gAppDelegate hideKeyboard];
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [self.controllerStack removeAllObjects];
    [self.controllerStack addObject:controller];
    controller.view.alpha = 0.0;
    controller.view.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:controller.view];
    [UIView animateWithDuration:(animated ? kControllerAnimatePeriod : 0.0) 
        animations:^{
            controller.view.alpha = 1.0;
        }
        completion:^(BOOL animated){

        }];
}

// ----------------------------------------------------------------------------

- (void) presentModalViewController:(UIViewController *)controller animated:(BOOL)animated {
    [gAppDelegate hideMenu];
    [gAppDelegate hideKeyboard];
    if (self.modalControllerStack.count > 0) {
        [self.modalControllerStack.lastObject viewWillDisappear:animated];
    } else {
        [self.controllerStack.lastObject viewWillDisappear:animated];
    }
    [self.modalControllerStack addObject:controller];
    controller.view.frame = CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);    
    [self.view addSubview:controller.view];
    controller.view.alpha = 0.0;
    [UIView animateWithDuration:(animated ? kModalAnimatePeriod : 0.0)
        animations:^{
            controller.view.alpha = 1.0;
            controller.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);    
        }
        completion:^(BOOL finished){

        }];
}

// ----------------------------------------------------------------------------

- (void) dismissModalViewControllerAnimated:(BOOL)animated {
    UIViewController *controller = self.modalControllerStack.lastObject;
    [self.modalControllerStack removeLastObject];
    UIViewController *revealed = (self.modalControllerStack.count > 0) ?
        self.modalControllerStack.lastObject : self.controllerStack.lastObject;
    [revealed viewWillAppear:animated];
    [UIView animateWithDuration:(animated ? kModalAnimatePeriod : 0.0) 
        animations:^{        
            controller.view.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);    
        } 
        completion:^(BOOL finished){
            [controller.view removeFromSuperview];
            [revealed viewDidAppear:animated];
        }];           
}

// ----------------------------------------------------------------------------

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    for (UIViewController *controller in self.modalControllerStack) {
        [controller willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    for (UIViewController *controller in self.controllerStack) {
        [controller willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

// ----------------------------------------------------------------------------

- (UIViewController *) topController {
    return self.controllerStack.lastObject;
}

// ----------------------------------------------------------------------------

@end
