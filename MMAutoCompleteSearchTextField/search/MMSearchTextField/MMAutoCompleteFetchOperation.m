//
//  MMAutoCompleteFetchOperation.m
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import "MMAutoCompleteFetchOperation.h"
#import "MMAutoCompletionObject.h"
#import "MMAutoCompletionSearchBar.h"

@implementation MMAutoCompleteFetchOperation{
    dispatch_semaphore_t sentinelSemaphore;
}

- (void) cancel
{
    dispatch_semaphore_signal(sentinelSemaphore);
    [super cancel];
}

- (void)main
{
    @autoreleasepool {
        
        if (self.isCancelled){
            return;
        }
        
        __weak MMAutoCompleteFetchOperation *operation = self;
        sentinelSemaphore = dispatch_semaphore_create(0);
        [self.dataSource autoCompleteSearchBar:self.searchBar
                           suggestionForString:self.incompleteString
                             completionHandler:^(NSArray *suggestions){
                                 [operation performSelector:@selector(didReceiveSuggestions:) withObject:suggestions];
                                 dispatch_semaphore_signal(sentinelSemaphore);
                             }];
        
        dispatch_semaphore_wait(sentinelSemaphore, DISPATCH_TIME_FOREVER);
        if(self.isCancelled){
            return;
        }
    }
}

- (void)didReceiveSuggestions:(NSArray *)suggestions
{
    if(suggestions == nil){
        suggestions = [NSArray array];
    }
    
    if(!self.isCancelled){
        
        if(suggestions.count){
            NSObject *firstObject = suggestions[0];
            NSAssert([firstObject isKindOfClass:[NSString class]] ||
                     [firstObject conformsToProtocol:@protocol(MMAutoCompletionObject)],
                     @"MLPAutoCompleteTextField expects an array with objects that are either strings or conform to the MLPAutoCompletionObject protocol for possible completions.");
        }
        
        NSDictionary *resultsInfo = @{kFetchedTermsKey: suggestions,
                                      kFetchedStringKey : self.incompleteString};
        [(NSObject *)self.delegate
         performSelectorOnMainThread:@selector(autoCompleteTermsDidFetch:)
         withObject:resultsInfo
         waitUntilDone:NO];
    };
}

- (id)initWithDelegate:(id<MMAutoCompleteFetchOperationDelegate>)aDelegate completionsDataSource:(id<MMAutoCompleteDataSource>)aDataSource autoCompleteSearchBar:(MMAutoCompletionSearchBar *)aSearchBar
{
    self = [super init];
    if (self) {
        [self setDelegate:aDelegate];
        [self setSearchBar:aSearchBar];
        [self setDataSource:aDataSource];
        [self setIncompleteString:aSearchBar.text];
        
        if(!self.incompleteString){
            self.incompleteString = @"";
        }
    }
    return self;
}

- (void)dealloc
{
    [self setDelegate:nil];
    [self setSearchBar:nil];
    [self setDataSource:nil];
    [self setIncompleteString:nil];
}


@end
