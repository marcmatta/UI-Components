//
//  UserVenueTuple.m
//  TerminalApp
//
//  Created by Marc on 5/19/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import "UserVenueTuple.h"
#import "AppCoreData.h"

@implementation UserVenueTuple

//@dynamic userId;
//@dynamic venueId;

+ (UserVenueTuple *)tupleWithVenueIndex:(NSNumber *)venueIndex userIndex:(NSNumber *)userIndex
{
//    NSManagedObjectContext *mOC = [AppCoreData sharedInstance].managedObjectContext;
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:mOC];
//    UserVenueTuple *tuple = [[UserVenueTuple alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:mOC];
    __autoreleasing UserVenueTuple *tuple = [UserVenueTuple new];
    tuple.venueId = venueIndex;
    tuple.userId = userIndex;
    return tuple;
}
@end
