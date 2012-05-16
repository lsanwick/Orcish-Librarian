//
//  DataManager.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/15/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DataManager : NSObject

+ (DataManager *) shared;

- (void) stageUpdatesFromServer;
- (BOOL) hasStagedUpdates;
- (BOOL) hasInstalledData;
- (void) installDataFromBundle;
- (void) installDataFromStage;

@property (nonatomic, readonly) NSString *databasePath;
@property (nonatomic, readonly) NSString *cardNamesTextPath;

@end
