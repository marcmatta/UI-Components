//
//  AppCoreData.m
//  TerminalApp
//
//  Created by Marc on 5/19/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import "AppCoreData.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "UserVenueTuple.h"

@interface AppCoreData ()
@property (nonatomic, strong) FMDatabase *db;
@end

@implementation AppCoreData

//@synthesize managedObjectModel=_managedObjectModel, managedObjectContext=_managedObjectContext, persistentStoreCoordinator=_persistentStoreCoordinator;

static AppCoreData *singleton;

+ (AppCoreData *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [AppCoreData new];
        [singleton populateDatabase];
    });
    return singleton;
}

- (void)populateDatabase
{
    self.db = [FMDatabase databaseWithPath:@"/tmp/tmp.db"];
    [self.db setShouldCacheStatements:YES];
    
    [self.db open];
    [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS CHECKINS (VenueId INT, UserId INT);"]; //Create SQLite Table
    [self.db executeUpdate:@"DELETE FROM CHECKINS"]; // Delete previously populated data
    [self.db close];
}

+ (NSInteger)maximumNumberOfCommonCheckInsWithCheckIns:(NSArray *)checkIns withMaxNumberOfVenues:(NSInteger)maxNumberOfVenues
{
    [[self sharedInstance] populateDatabase];
    
    @autoreleasepool {
        __block NSInteger commonCheckIns = 0;
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:@"/tmp/tmp.db"];
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"DELETE FROM CHECKINS"]; // Delete Previous Records If they exist
            
            for (UserVenueTuple *tuple in checkIns) {
                [db executeUpdate:@"INSERT INTO CHECKINS (VenueId, UserId) VALUES (?, ?)", tuple.venueId, tuple.userId];
            }
            
            FMResultSet *set = [db executeQuery:@"SELECT  COUNT (*) FROM\
                                                (\
                                                    SELECT COUNT (VenueId) as c FROM CheckIns Group BY UserId\
                                                )\
                                                WHERE c >= 2;", @(maxNumberOfVenues)];
            if ([set next])
                commonCheckIns = [set intForColumnIndex:0];
            [set close];
        }];
        
        return commonCheckIns;
    }
}

@end
