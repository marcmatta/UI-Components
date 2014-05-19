//
//  AppLogic.m
//  TerminalApp
//
//  Created by Marc on 5/16/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import "AppLogic.h"
#import "UserVenueTuple.h"
#import "AppCoreData.h"

@interface AppLogic ()
@property NSInteger step;
@property NSInteger numberOfMaximumVenues;
@property NSInteger numberOfMaximumCheckIns;
@property (strong) NSMutableArray *checkIns;
@property (nonatomic, strong) NSNumberFormatter *formatter;
@end

@implementation AppLogic
static NSString *const NANString = @"The value you have entered is NAN or not in range. Please choose one from [1-9]";
static NSString *const InvalidTupleErrorString = @"Invalid Venue Index - UserIndex Tuple. E.g. 0 1";
static NSString *const TupleAlreadyAvailable = @"Please choose another tuple";

- (instancetype)init
{
    self = [super init];
    if (self)
        [self initialize];
    
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize
{
    _step = -1;
    _numberOfMaximumCheckIns = 0;
    _numberOfMaximumVenues = 0;
    _checkIns = [NSMutableArray array];
}

#pragma mark - Getters -
- (NSNumberFormatter *)formatter
{
    if (!_formatter)
    {
        _formatter = [[NSNumberFormatter alloc] init];
        _formatter.allowsFloats = NO;
        _formatter.formatterBehavior = NSNumberFormatterBehavior10_4;
        _formatter.numberStyle = NSNumberFormatterDecimalStyle;
        _formatter.maximumIntegerDigits = 1; //For simplicity sake
        _formatter.minimum = @(0);
        _formatter.maximum = @(9);
    }
    return _formatter;
}

#pragma mark - 
- (NSString *)outputForCheckInAtIndex:(NSInteger)checkInIndex
{
    return [NSString stringWithFormat:@"Enter CheckIn number %i", checkInIndex];
}

- (NSString *)numberOfCommonCheckIns
{
    return [@([AppCoreData maximumNumberOfCommonCheckInsWithCheckIns:self.checkIns withMaxNumberOfVenues:self.numberOfMaximumVenues]) stringValue];
}

#pragma mark - Public -

- (NSString *)commandOutput:(NSString *)command
{
    switch (_step) {
        case -1:
        {
            self.step ++;
        }
            return @"Enter The number of maximum Venues";
            break;
        case 0:
        {
            NSNumber *numberOfMaximumVenues = [self.formatter numberFromString:command];
            if (numberOfMaximumVenues)
            {
                self.numberOfMaximumVenues = [numberOfMaximumVenues integerValue];
                self.step ++;
                return @"Enter The Number of Maximum Check-ins";
            }else
                return NANString;
        }
            break;
        case 1:
        {
            NSNumber *numberOfMaximumCheckIns = [self.formatter numberFromString:command];
            if (numberOfMaximumCheckIns)
            {
                self.numberOfMaximumCheckIns = [numberOfMaximumCheckIns integerValue];
                self.step ++;
                return [self outputForCheckInAtIndex:self.checkIns.count];
            }else
                return NANString;
        }
            break;
        case 2:
        {
            NSArray *tuple = [command componentsSeparatedByString:@" "];
            if (tuple.count != 2)
                return InvalidTupleErrorString;
            else{
                NSNumber *venueIndex = [self.formatter numberFromString:tuple[0]];
                NSNumber *userIndex = [self.formatter numberFromString:tuple[1]];
                
                if (!venueIndex || !userIndex)
                    return InvalidTupleErrorString;
                else{
                    // Verify tuple does not previously exist
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"venueId = %@ AND userId = %@", venueIndex, userIndex];
                    NSArray *similarCheckIns = [self.checkIns filteredArrayUsingPredicate:predicate];
                    if (similarCheckIns.count > 0)
                        return TupleAlreadyAvailable;
                    else{
                        [self.checkIns addObject:[UserVenueTuple tupleWithVenueIndex:venueIndex userIndex:userIndex]];
                        if (self.checkIns.count == self.numberOfMaximumCheckIns){
                            NSString * output = [[self numberOfCommonCheckIns] stringByAppendingFormat:@" common Checkins. \n\n\n%@", @"Enter The number of maximum Venues"];
                            [self initialize];
                            return output;
                        }else{
                            return [self outputForCheckInAtIndex:self.checkIns.count];
                        }
                    }
                }
            }
        }
            break;
        default:break;
    }
    return @"test";
}
@end
