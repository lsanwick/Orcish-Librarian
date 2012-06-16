//
//  MenuController.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 10/22/11.
//  Copyright (c) 2011 Orcish. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MenuController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *menuView;
@property (readonly, nonatomic) NSArray *menuItems; 

- (void) viewDidLoad;
- (NSArray *) menuSections;
- (NSArray *) menuItems;

@end
