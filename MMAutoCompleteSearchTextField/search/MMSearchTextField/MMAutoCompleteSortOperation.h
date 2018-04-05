//
//  MMAutoCompleteSortOperation.h
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import <Foundation/Foundation.h>
#import "MMAutoCompleteSortOperationDelegate.h"

typedef NS_OPTIONS(NSUInteger, MMSortOperationType) {
    MMSortUsingLevensteinDistance = 1 << 0,
    MMSortUsingStringScore = 1<<1
};

@interface MMAutoCompleteSortOperation : NSOperation
@property (strong) NSString *incompleteString;
@property (strong) NSArray *possibleCompletions;
@property (strong) id <MMAutoCompleteSortOperationDelegate> delegate;
@property (assign) MMSortOperationType operationType;
- (id)initWithDelegate:(id<MMAutoCompleteSortOperationDelegate>)aDelegate
      incompleteString:(NSString *)string
   possibleCompletions:(NSArray *)possibleStrings
         operationType:(MMSortOperationType)operationType;

- (NSArray *)sortedCompletionsForString:(NSString *)inputString
                    withPossibleStrings:(NSArray *)possibleTerms;
@end
