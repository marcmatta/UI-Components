//
//  MMAutoCompleteSortOperationDelegate.h
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import <Foundation/Foundation.h>

@protocol MMAutoCompleteSortOperationDelegate <NSObject>
- (void)autoCompleteTermsDidSort:(NSArray *)completions;
@end
