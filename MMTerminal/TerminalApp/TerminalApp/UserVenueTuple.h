//
//  UserVenueTuple.h
//  TerminalApp
//
//  Created by Marc on 5/19/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>

//@interface UserVenueTuple : NSManagedObject
@interface UserVenueTuple : NSObject
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * venueId;
+ (UserVenueTuple *)tupleWithVenueIndex:(NSNumber *)venueIndex userIndex:(NSNumber *)userIndex;
@end
