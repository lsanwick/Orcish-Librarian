//
//  MenuController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/22/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import "MenuController.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "DataManager.h"


@implementation MenuController

@synthesize menuView;


// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    menuView.separatorStyle = UITableViewCellSeparatorStyleNone;
    menuView.backgroundColor = UIColorFromRGB(0x32394a);
    menuView.scrollsToTop = NO;
}

// ----------------------------------------------------------------------------

- (NSArray *) menuSections {
    static NSArray *sections = nil;
    if (!sections) {
        sections = [NSArray arrayWithObjects:
            @"",
            @"Orcish Librarian",
            nil];
    }
    return sections;
}

// ----------------------------------------------------------------------------

- (NSArray *) menuItems {
    static NSArray *items = nil;
    if (!items) {
        items = [NSArray arrayWithObjects:
            [NSArray arrayWithObjects:
                @"Basic Search",
                //@"Advanced Search",
                @"Browse Sets", 
                @"Bookmarks", 
                @"Random Cards", 
                nil],
            [NSArray arrayWithObjects:
                @"About",
                nil],
            nil];
    }
    return items;
}

// ----------------------------------------------------------------------------
//  UIScrollViewDelegate
// ----------------------------------------------------------------------------

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [gAppDelegate hideKeyboard];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate
// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"MenuCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Menu-Row"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Menu-Row-Selected"]];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = UIColorFromRGB(0xc4ccda);
        cell.textLabel.shadowColor = UIColorFromRGB(0x212631);
        cell.textLabel.shadowOffset = CGSizeMake(0.0, 2.0);
        cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    }
    cell.textLabel.text = [[self.menuItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

// ----------------------------------------------------------------------------

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([[self.menuSections objectAtIndex:section] isEqualToString:@""]) ? 0.0f : 22.0f;
}

// ----------------------------------------------------------------------------

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static UIImage *backgroundImage;
    if (!backgroundImage) {
        backgroundImage = [UIImage imageNamed:@"Menu-Section"];
    }
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 260.0, 22.0)];
    UIView *background = [[UIImageView alloc] initWithImage:backgroundImage];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 250.0, 22.0)];
    label.text = [[self.menuSections objectAtIndex:section] uppercaseString];
    label.font = [UIFont boldSystemFontOfSize:11.0];
    label.textColor = UIColorFromRGB(0xc4ccda);
    label.shadowColor = UIColorFromRGB(0x272d39);
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.backgroundColor = [UIColor clearColor];
    [header addSubview:background];
    [header addSubview:label];
    return header;
}

// ----------------------------------------------------------------------------

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    NSString *text = [[[self.menuItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] uppercaseString];
    
    // HOME (BASIC SEARCH)
    if ([text isEqualToString:@"BASIC SEARCH"]) {
        [gAppDelegate trackEvent:@"Menu" action:@"Basic Search" label:@""];
        [gAppDelegate showBasicSearchController];
    } 
    
    // ADVANCED SEARCH
    if ([text isEqualToString:@"ADVANCED SEARCH"]) {
        [gAppDelegate trackEvent:@"Menu" action:@"Advanced Search" label:@""];
        [gAppDelegate showAdvancedSearchController];
    }
    
    // BOOKMARKS
    else if ([text isEqualToString:@"BOOKMARKS"]) {
        [gAppDelegate trackEvent:@"Menu" action:@"Bookmarks" label:@""];
        [gAppDelegate showBookmarkController];
    }
    
    // RANDOM CARD
    else if ([text isEqualToString:@"RANDOM CARDS"]) {
        [gAppDelegate trackEvent:@"Menu" action:@"Random Cards" label:@""];
        [gAppDelegate showRandomCardController];
    }
    
    // BROWSE BY SET
    else if ([text isEqualToString:@"BROWSE SETS"]) {
        [gAppDelegate trackEvent:@"Menu" action:@"Browse Sets" label:@""];
        [gAppDelegate showBrowseController];
    }
    
    // ABOUT
    else if ([text isEqualToString:@"ABOUT"]) {
        [gAppDelegate trackEvent:@"Menu" action:@"About" label:@""];
        [gAppDelegate showAboutController];
    }
    
    [gAppDelegate hideMenu];
    [gAppDelegate hideKeyboard];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// ----------------------------------------------------------------------------
//  UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuItems.count;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.menuItems objectAtIndex:section] count];
}

// ----------------------------------------------------------------------------

@end
