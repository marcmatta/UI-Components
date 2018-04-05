//
//  MMPerson.h
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import <Foundation/Foundation.h>
#import "MMAutoCompletionObject.h"

@interface MMPerson : NSObject <MMAutoCompletionObject>
@property (nonatomic, strong) NSString *name;

- (id)initWithName:(NSString *)name;
@end
