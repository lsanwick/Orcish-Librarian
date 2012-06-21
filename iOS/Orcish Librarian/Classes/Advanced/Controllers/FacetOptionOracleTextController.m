//
//  FacetOptionOracleTextController.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 6/17/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "FacetOptionOracleTextController.h"
#import "SearchFacet.h"

@interface FacetOptionOracleTextController ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation FacetOptionOracleTextController

@synthesize textField;

// ----------------------------------------------------------------------------

- (void) viewDidLoad {
    [super viewDidLoad];
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
}

// ----------------------------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

// ----------------------------------------------------------------------------

- (SearchFacet *) createFacet {
    return [SearchFacet facetWithTitleText:self.textField.text];
}

// ----------------------------------------------------------------------------
//  UITableViewDelegate and UITableViewDataSource
// ----------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

// ----------------------------------------------------------------------------

- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// ----------------------------------------------------------------------------

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Text to search for:";
}

// ----------------------------------------------------------------------------

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FacetOptionCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textField.frame = CGRectMake(
            cell.contentView.bounds.origin.x + 20.0, 
            cell.contentView.bounds.origin.y + 12.0, 
            cell.contentView.bounds.size.width - 36.0, 
            23.0);
        [cell addSubview:self.textField];
    }         
    return cell;
}

// ----------------------------------------------------------------------------

@end
