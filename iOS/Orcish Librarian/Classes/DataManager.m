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

#define MAJOR(v)  ([DataManager majorNumberForVersion:(v)])
#define MINOR(v)  ([DataManager minorNumberForVersion:(v)])



@interface DataManager () {
    FMDatabase *db;
    NSData *names;
}

+ (NSString *) majorNumberForVersion:(NSString *)version;
+ (NSString *) minorNumberForVersion:(NSString *)version;

- (BOOL) canUpdateTo:(NSString *)version;
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

+ (NSString *) majorNumberForVersion:(NSString *)version {
    return [version stringByReplacingOccurrencesOfRegex:@"^\\s*(\\d+).*$" withString:@"$1"];
}

// ----------------------------------------------------------------------------

+ (NSString *) minorNumberForVersion:(NSString *)version {
     return [version stringByReplacingOccurrencesOfRegex:@"^.*?(\\d+)\\s*$" withString:@"$1"];
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

- (NSString *) version {
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"dataVersion"];
    if (!currentVersion || [MAJOR(currentVersion) compare:MAJOR(bundleVersion) options:NSNumericSearch] == NSOrderedAscending) {
        return bundleVersion;
    } else {
        return currentVersion;
    }
}

// ----------------------------------------------------------------------------

- (void) setVersion:(NSString *)version {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:@"dataVersion"];
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

- (BOOL) canUpdateTo:(NSString *)version {
    // major versions must be identical
    // minor version of update must be higher than existing minor version
    return [MAJOR(self.version) isEqualToString:MAJOR(version)] &&
        [MINOR(self.version) compare:MINOR(version) options:NSNumericSearch] == NSOrderedAscending;
}

// ----------------------------------------------------------------------------

- (void) updateFromServer {    
    @try {
        NSError *error; 

        NSURL *versionURL = [NSURL URLWithString:@"http://d1g6xmf8vayz1g.cloudfront.net/database/version.txt"];
        NSString *version = [NSString stringWithContentsOfURL:versionURL encoding:NSUTF8StringEncoding error:&error];
        if (!version || ![self canUpdateTo:version]) {
            return;
        }
        
        // NSLog(@"Downloading new data from server");
        NSURL *dataURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://d1g6xmf8vayz1g.cloudfront.net/database/cards-%@.sqlite3", version]];
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
            self.version = version;
            [self installDatabaseFile:stagedDbPath andNamesFile:stagedNamesPath forVersion:version];
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
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"cards-%@.sqlite3", self.version]];
}

// ----------------------------------------------------------------------------

- (NSString *) namesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"card-names.txt"];    
}

// ----------------------------------------------------------------------------

- (BOOL) hasInstalledData {
    NSFileManager *fm = [NSFileManager defaultManager];
    return ([fm fileExistsAtPath:self.dbPath] && [fm fileExistsAtPath:self.namesPath]);
}

// ----------------------------------------------------------------------------

- (void) installDataFromBundle {
    // NSLog(@"Installing packaged data from bundle");
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cards.sqlite3"];
    NSString *namesPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"card-names.txt"];
    [fm removeItemAtPath:self.dbPath error:&error];
    [fm removeItemAtPath:self.namesPath error:&error];
    [fm copyItemAtPath:dbPath toPath:self.dbPath error:&error];
    [fm copyItemAtPath:namesPath toPath:self.namesPath error:&error];
}

// ----------------------------------------------------------------------------

- (void) installDatabaseFile:(NSString *)dbPath andNamesFile:(NSString *)namesPath forVersion:(NSString *)version {
    // NSLog(@"Installing downloaded data");
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
