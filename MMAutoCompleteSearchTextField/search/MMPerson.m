//
//  MMPerson.m
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import "MMPerson.h"

@implementation MMPerson

- (id)initWithName:(NSString *)name
{
    if (self = [super init])
        _name = name;
    return self;
}

- (NSString *)autoCompletionValue
{
    return _name;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ : %@", [super debugDescription], _name];
}
@end
