//
//  AboutController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/20/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "AboutController.h"
#import "AppDelegate.h"
#import "DataManager.h"

@interface AboutController ()

@end

@implementation AboutController

@synthesize version;
@synthesize lastUpdated;

// ----------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.version.text = [NSString stringWithFormat:@"v.%@", 
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    self.lastUpdated.hidden = !gDataManager.lastUpdated;
    if (gDataManager.lastUpdated) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateStyle = NSDateFormatterMediumStyle;
        NSString *formattedDate = [format stringFromDate:gDataManager.lastUpdated];
        self.lastUpdated.text = [NSString stringWithFormat:@"Last updated on %@", formattedDate];
    }
}

// ----------------------------------------------------------------------------

- (IBAction) urlTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://orcish.info"]];
}

// ----------------------------------------------------------------------------

@end