//
//  MMAutoCompleteFetchOperation.h
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import <Foundation/Foundation.h>
#import "MMAutoCompleteFetchOperationDelegate.h"
#import "MMAutoCompleteDataSource.h"

static NSString *kFetchedTermsKey = @"terms";
static NSString *kFetchedStringKey = @"fetchInputString";

@class MMAutoCompletionSearchBar;
@interface MMAutoCompleteFetchOperation : NSOperation
@property (strong) NSString *incompleteString;
@property (strong) MMAutoCompletionSearchBar *searchBar;
@property (strong) id <MMAutoCompleteFetchOperationDelegate> delegate;
@property (strong) id <MMAutoCompleteDataSource> dataSource;

- (id)initWithDelegate:(id<MMAutoCompleteFetchOperationDelegate>)aDelegate
 completionsDataSource:(id<MMAutoCompleteDataSource>)aDataSource
 autoCompleteSearchBar:(MMAutoCompletionSearchBar *)aSearchBar;
@end
