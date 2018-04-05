//
//  MMAutoCompleteDataSource.h
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import <Foundation/Foundation.h>
@class MMAutoCompletionSearchBar;
@protocol MMAutoCompleteDataSource <NSObject>
- (void)autoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar suggestionForString:(NSString*)string completionHandler:(void (^)(NSArray *dataSource))completionHandler;
@end
