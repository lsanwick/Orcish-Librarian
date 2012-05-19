//
//  DataManager.h
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/15/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import <UIKit/UIKit.h>


#define gDataManager ([DataManager shared])

@class FMDatabase;

@interface DataManager : NSObject

+ (DataManager *) shared;

- (BOOL) hasInstalledData;
- (void) installDataFromBundle;
- (void) updateFromServer;
- (void) activateDataSources;
- (void) deactivateDataSources;

- (FMDatabase *) db;
- (NSData *) names;

@end
