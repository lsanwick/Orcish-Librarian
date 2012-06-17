//
//  FacetCustomizationController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/16/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "FacetCustomizationController.h"

@interface FacetCustomizationController ()

@end

@implementation FacetCustomizationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
