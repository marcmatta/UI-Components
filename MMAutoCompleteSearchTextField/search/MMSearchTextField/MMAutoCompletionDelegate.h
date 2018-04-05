//
//  MMAutoCompletionDelegate.h
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import <Foundation/Foundation.h>
@class MMAutoCompletionSearchBar;
@protocol MMAutoCompletionObject;

@protocol MMAutoCompletionDelegate <NSObject>

- (void)presentResultsForAutoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar;
- (void)hideResultsForAutoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar;
- (void)autoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar didSelectAutoCompleteObject:(id<MMAutoCompletionObject>)completionObject;
- (void)autoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar configureTableViewCell:(UITableViewCell *)tableViewCell withCompletionObject:(id<MMAutoCompletionObject>)completionObject;
@optional
- (void)autoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar willDisplayCell:(UITableViewCell *)tableViewCell withCompletionObject:(id<MMAutoCompletionObject>)completionObject;
@end
