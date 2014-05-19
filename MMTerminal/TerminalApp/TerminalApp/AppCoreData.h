//
//  AppCoreData.h
//  TerminalApp
//
//  Created by Marc on 5/19/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppCoreData : NSObject

//@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (AppCoreData *)sharedInstance;
+ (NSInteger)maximumNumberOfCommonCheckInsWithCheckIns:(NSArray *)checkIns withMaxNumberOfVenues:(NSInteger)maxNumberOfVenues;
@end
