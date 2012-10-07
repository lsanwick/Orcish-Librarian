//
//  DataManager.m
//  Orcish Librarian
//
//  Created by Stewart Ulm on 5/15/12.
//  Copyright (c) 2012 Orcish. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "FMDatabase.h"
#import "RegexKitLite.h"


@interface DataManager () {
    FMDatabase *db;
    NSData *names;
}

- (void) deleteExistingDataFiles;
- (BOOL) createNamesFile:(NSString *)namesPath fromDatabaseFile:(NSString *)dbPath;
- (void) installDatabaseFile:(NSString *)dbPath andNamesFile:(NSString *)namesPath forVersion:(NSString *)version;
- (NSString *) dbPath;
- (NSString *) namesPath;

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

- (FMDatabase *) db {
    return db;
}

// ----------------------------------------------------------------------------

- (NSData *) names {
    return names;
}

// ----------------------------------------------------------------------------

- (NSString *) dataVersion {
    NSString *dataVersion = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"dataVersion-%@", gAppDelegate.version]];
    return dataVersion ? dataVersion : @"0";    
}

// ----------------------------------------------------------------------------

- (void) setDataVersion:(NSString *)version {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:[NSString stringWithFormat:@"dataVersion-%@", gAppDelegate.version]];
    [defaults synchronize];
}

// ----------------------------------------------------------------------------

- (NSDate *) lastUpdated {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdated"];
}

// ----------------------------------------------------------------------------

- (void) setLastUpdated:(NSDate *)lastUpdated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastUpdated forKey:@"lastUpdated"];
    [defaults synchronize];
}

// ----------------------------------------------------------------------------

- (void) updateFromServer {    
    @try {
        NSError *error; 
        
        NSURL *versionURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://orcish.info/database/%@/latest.txt", gAppDelegate.version]];
        NSString *availableVersion = [NSString stringWithContentsOfURL:versionURL encoding:NSUTF8StringEncoding error:&error];
        if (!availableVersion || [self.dataVersion compare:availableVersion options:NSNumericSearch] != NSOrderedAscending) {
            return;
        }
        
        NSURL *dataURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://orcish.info/database/%@/%@/orcish.sqlite3", gAppDelegate.version, availableVersion]];
        NSData *data = [NSData dataWithContentsOfURL:dataURL options:0 error:&error];
        if (!data) {
            return;
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *stagedDbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
        NSString *stagedNamesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];    
        if (![data writeToFile:stagedDbPath atomically:YES] || ![self createNamesFile:stagedNamesPath fromDatabaseFile:stagedDbPath]) {
            return;
        }
                
        dispatch_sync(gAppDelegate.dataQueue, ^{
            [self deactivateDataSources];
            self.dataVersion = availableVersion;
            [self installDatabaseFile:stagedDbPath andNamesFile:stagedNamesPath forVersion:availableVersion];
            [self activateDataSources];
        });
    }
    @finally {
        self.lastUpdated = [NSDate date];
    }
}

// ----------------------------------------------------------------------------

- (NSString *) dbPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"orcish-%@.%@.sqlite3", gAppDelegate.version, self.dataVersion]];
}

// ----------------------------------------------------------------------------

- (NSString *) namesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"orcish.names"];    
}

// ----------------------------------------------------------------------------

- (BOOL) hasInstalledData {
    NSFileManager *fm = [NSFileManager defaultManager];
    return ([fm fileExistsAtPath:self.dbPath] && [fm fileExistsAtPath:self.namesPath]);
}

// ----------------------------------------------------------------------------

- (void) installDataFromBundle {
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"orcish.sqlite3"];
    NSString *namesPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"orcish.names"];
    [fm removeItemAtPath:self.dbPath error:&error];
    [fm removeItemAtPath:self.namesPath error:&error];
    [fm copyItemAtPath:dbPath toPath:self.dbPath error:&error];
    [fm copyItemAtPath:namesPath toPath:self.namesPath error:&error];
}

// ----------------------------------------------------------------------------

- (void) deleteExistingDataFiles {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *file in [fm contentsOfDirectoryAtPath:docPath error:&error]) {
        [fm removeItemAtPath:[docPath stringByAppendingPathComponent:file] error:&error];
    }
}

// ----------------------------------------------------------------------------

- (void) installDatabaseFile:(NSString *)dbPath andNamesFile:(NSString *)namesPath forVersion:(NSString *)version {
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.dbPath error:&error];
    [fm removeItemAtPath:self.namesPath error:&error];
    [fm moveItemAtPath:dbPath toPath:self.dbPath error:&error];
    [fm moveItemAtPath:namesPath toPath:self.namesPath error:&error];
}

// ----------------------------------------------------------------------------

- (BOOL) createNamesFile:(NSString *)namesPath fromDatabaseFile:(NSString *)dbPath {
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    if (![database open]) {
        return NO;
    }
    @try {
        [[NSFileManager defaultManager] createFileAtPath:namesPath contents:nil attributes:nil];
        NSFileHandle *namesFile = [NSFileHandle fileHandleForWritingAtPath:namesPath];
        if (!namesFile) {
            return NO;
        } 
        NSData *separator = [@"|" dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *allNames = [NSMutableDictionary dictionary];
        FMResultSet *rs = [database executeQuery:@"SELECT search_name, name_hash FROM cards"];    
        while ([rs next]) {
            NSString *name = [rs stringForColumn:@"search_name"];
            NSString *hash = [rs stringForColumn:@"name_hash"];
            if ([allNames objectForKey:name] == nil) {
                [allNames setObject:[NSNull null] forKey:name];
                [namesFile writeData:separator];
                [namesFile writeData:[name dataUsingEncoding:NSUTF8StringEncoding]];
                [namesFile writeData:separator];
                [namesFile writeData:[hash dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }    
        [rs close];
        [namesFile writeData:separator];
        [namesFile closeFile];
        return YES;
    }
    @finally {
        [database close];
    }    
}

// ----------------------------------------------------------------------------

- (void) activateDataSources {
    if (!self.hasInstalledData) {
        [self deleteExistingDataFiles];
        [self installDataFromBundle];
    }
    NSError *error;
    names = [NSData dataWithContentsOfFile:self.namesPath options:NSDataReadingMappedAlways error:&error];
    db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
}

// ----------------------------------------------------------------------------

- (void) deactivateDataSources {
    [db close];
    db = nil;
    names = nil;
}

// ----------------------------------------------------------------------------

@end
