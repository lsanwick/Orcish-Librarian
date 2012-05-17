//
//  DataManager.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/15/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "RegexKitLite.h"


@interface DataManager ()

- (BOOL) stageData:(NSData *)data forVersion:(NSString *)version;
- (BOOL) isDatabaseSane:(FMDatabase *)database;
- (BOOL) createNameFile:(NSString *)path fromDatabase:(FMDatabase *)database;

@end


@implementation DataManager

// ----------------------------------------------------------------------------

+ (DataManager *) shared {
    static DataManager *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[DataManager alloc] init];
    });
    return singleton;
}

// ----------------------------------------------------------------------------

- (void) stageUpdatesFromServer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        NSURL *versionUrl = [NSURL URLWithString:@"http://direct.orcish.info/librarian/db/version.txt"];        
        NSString *upgradeVersion = [NSString stringWithContentsOfURL:versionUrl encoding:NSUTF8StringEncoding error:&error];
        if (upgradeVersion) {
            NSString *currentVersion = gAppDelegate.databaseVersion;
            NSString *currentMajorVersion = [currentVersion stringByReplacingOccurrencesOfRegex:@"^\\s*(\\d+).*$" withString:@"$1"];
            NSString *upgradeMajorVersion = [upgradeVersion stringByReplacingOccurrencesOfRegex:@"^\\s*(\\d+).*$" withString:@"$1"];
            if ([currentMajorVersion isEqualToString:upgradeMajorVersion]) {
                NSString *currentMinorVersion = [currentVersion stringByReplacingOccurrencesOfRegex:@"^.*?(\\d+)\\s*$" withString:@"$1"];
                NSString *upgradeMinorVersion = [upgradeVersion stringByReplacingOccurrencesOfRegex:@"^.*?(\\d+)\\s*$" withString:@"$1"];
                if ([currentMinorVersion compare:upgradeMinorVersion options:NSNumericSearch] == NSOrderedAscending) {
                    NSURL *databaseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://direct.orcish.info/librarian/db/cards-%@.sqlite3", upgradeVersion]];
                    NSData *databaseData = [NSData dataWithContentsOfURL:databaseUrl options:0 error:&error];
                    if (databaseData != nil) {
                        if ([self stageData:databaseData forVersion:upgradeVersion]) {
                            [[NSUserDefaults standardUserDefaults] setObject:upgradeVersion forKey:@"stagingVersion"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            // TODO: alert the UI
                            NSLog(@"Staged Update Waiting...");
                        }
                    }
                }
            }
        }
    });
}

// ----------------------------------------------------------------------------

- (BOOL) hasStagedUpdates {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"stagingVersion"] != nil;
}

// ----------------------------------------------------------------------------

- (NSString *) databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cards.sqlite3"];    
}

// ----------------------------------------------------------------------------

- (NSString *) cardNamesTextPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"card-names.txt"];    
}

// ----------------------------------------------------------------------------

- (BOOL) hasInstalledData {
    NSFileManager *fm = [NSFileManager defaultManager];
    return ([fm fileExistsAtPath:self.databasePath] && [fm fileExistsAtPath:self.cardNamesTextPath]);
}

// ----------------------------------------------------------------------------

- (void) installDataFromBundle {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSString *databasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cards.sqlite3"];
    NSString *cardNamesTextPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"card-names.txt"];
    [fm removeItemAtPath:self.databasePath error:&error];
    [fm removeItemAtPath:self.cardNamesTextPath error:&error];
    [fm copyItemAtPath:databasePath toPath:self.databasePath error:&error];
    [fm copyItemAtPath:cardNamesTextPath toPath:self.cardNamesTextPath error:&error];    
}

// ----------------------------------------------------------------------------

- (void) installDataFromStage {
    NSError *error;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *stagingVersion = [defaults objectForKey:@"stagingVersion"];
    if (stagingVersion) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *stagingPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"staging"];
        NSString *databasePath = [stagingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"cards-%@.sqlite3", stagingVersion]];
        NSString *cardNamesTextPath = [stagingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"card-names-%@.txt", stagingVersion]];
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:self.databasePath error:&error];
        [fm removeItemAtPath:self.cardNamesTextPath error:&error];
        if ([fm copyItemAtPath:databasePath toPath:self.databasePath error:&error] && [fm copyItemAtPath:cardNamesTextPath toPath:self.cardNamesTextPath error:&error]) {
            gAppDelegate.databaseVersion = stagingVersion;
        }
        [defaults removeObjectForKey:@"stagingVersion"];
        [defaults synchronize];
    }
}

// ----------------------------------------------------------------------------

- (BOOL) stageData:(NSData *)data forVersion:(NSString *)version {
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *stagingPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"staging"];
    NSString *dbPath = [stagingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"cards-%@.sqlite3", version]];
    [fm createDirectoryAtPath:stagingPath withIntermediateDirectories:YES attributes:nil error:&error];
    if ([data writeToFile:dbPath atomically:YES]) {
        FMDatabase *stagingDB = [FMDatabase databaseWithPath:dbPath];
        if ([stagingDB open] && [self isDatabaseSane:stagingDB]) {
            NSString *namesPath = [stagingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"card-names-%@.txt", version]];            ;
            if ([fm createFileAtPath:namesPath contents:nil attributes:nil] && [self createNameFile:namesPath fromDatabase:stagingDB]) {
                [stagingDB close]; 
                return YES;
            }
        } else {
            [stagingDB close]; 
        }               
    }
    return NO;
}

// ----------------------------------------------------------------------------

- (BOOL) createNameFile:(NSString *)path fromDatabase:(FMDatabase *)database {
    NSMutableDictionary *names = [NSMutableDictionary dictionary];
    NSFileHandle *nameFile = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!nameFile) {
        return NO;
    } else {
        NSData *separator = [@"|" dataUsingEncoding:NSUTF8StringEncoding];
        FMResultSet *rs = [database executeQuery:@"SELECT search_name, name_hash FROM cards"];    
        while ([rs next]) {
            NSString *name = [rs stringForColumn:@"search_name"];
            NSString *hash = [rs stringForColumn:@"name_hash"];
            if ([names objectForKey:name] == nil) {
                [names setObject:[NSNull null] forKey:name];
                [nameFile writeData:separator];
                [nameFile writeData:[name dataUsingEncoding:NSUTF8StringEncoding]];
                [nameFile writeData:separator];
                [nameFile writeData:[hash dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        [rs close];
        [nameFile writeData:separator];
        [nameFile closeFile];
        return YES;
    }
}

// ----------------------------------------------------------------------------

- (BOOL) isDatabaseSane:(FMDatabase *)database {
    return YES;
    /*
    FMResultSet *rs = [database executeQuery:@"SELECT COUNT(*) AS count FROM cards"];
    if (![rs next] || [rs intForColumn:@"count"] < 10000) {
        [rs close];
        return NO;
    }    
    [rs close];
    rs = [database executeQuery:@"SELECT COUNT(*) AS count FROM sets"];
    if (![rs next] || [rs intForColumn:@"count"] < 100) {
        [rs close];
        return NO;        
    }
    [rs close];
    return YES;    
    */
}

// ----------------------------------------------------------------------------

@end
