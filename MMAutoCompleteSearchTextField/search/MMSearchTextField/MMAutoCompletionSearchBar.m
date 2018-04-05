//
//  MMAutoCompletionSearchBar.m
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import "MMAutoCompletionSearchBar.h"
#import "MMAutoCompleteSortOperationDelegate.h"
#import "MMAutoCompleteFetchOperationDelegate.h"
#import "MMAutoCompleteTableViewCellDelegate.h"
#import "MMAutoCompletionObject.h"
#import "MMAutoCompleteFetchOperation.h"
#import "MMAutoCompleteSortOperation.h"

static NSString *kMMSortInputStringKey = @"sortInputString";
static NSString *kMMSortEditDistancesKey = @"editDistances";
static NSString *kMMSortObjectKey = @"sortObject";
const NSTimeInterval kMMDefaultAutoCompleteRequestDelay = 0.1;
static NSString *const kMMDefaultTableViewCellIdentifier = @"Cell";

@interface MMAutoCompletionSearchBar () <MMAutoCompleteSortOperationDelegate, MMAutoCompleteFetchOperationDelegate, UISearchBarDelegate>
@property (strong) NSArray *autoCompleteSuggestions;
@property (strong) NSOperationQueue *autoCompleteSortQueue;
@property (strong) NSOperationQueue *autoCompleteFetchQueue;
@end

@implementation MMAutoCompletionSearchBar

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.delegate = self;
    self.autoCompleteRowHeight = 44.f;
    self.autoCompleteFetchRequestDelay = kMMDefaultAutoCompleteRequestDelay;
    self.tableViewCellIdentifier = kMMDefaultTableViewCellIdentifier;
    [self setAutoCompleteSortQueue:[NSOperationQueue new]];
    self.autoCompleteSortQueue.name = [NSString stringWithFormat:@"Autocomplete Queue %i", arc4random()];
    
    [self setAutoCompleteFetchQueue:[NSOperationQueue new]];
    self.autoCompleteFetchQueue.name = [NSString stringWithFormat:@"Fetch Queue %i", arc4random()];
}

- (void)reloadData
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(fetchAutoCompleteSuggestions)
                                               object:nil];
    
    [self performSelector:@selector(fetchAutoCompleteSuggestions)
               withObject:nil
               afterDelay:self.autoCompleteFetchRequestDelay];
}

#pragma mark - Class Methods -
- (void)fetchAutoCompleteSuggestions
{
    [self.autoCompleteFetchQueue cancelAllOperations];
    
    MMAutoCompleteFetchOperation *fetchOperation = [[MMAutoCompleteFetchOperation alloc]
                                                     initWithDelegate:self
                                                     completionsDataSource:self.autoCompleteDataSource
                                                     autoCompleteSearchBar:self];
    
    [self.autoCompleteFetchQueue addOperation:fetchOperation];
}

#pragma mark - Setters -
- (void)setAutoCompleteTableView:(UITableView *)autoCompleteTableView
{
    _autoCompleteTableView = autoCompleteTableView;
    autoCompleteTableView.delegate = self;
    autoCompleteTableView.dataSource = self;
}

#pragma mark - MMAutoCompleteSortOperationDelegate -
- (void)autoCompleteTermsDidSort:(NSArray *)completions
{
    [self setAutoCompleteSuggestions:completions];
    [self.autoCompleteTableView reloadData];
}

#pragma mark - MMAutoCompleteFetchOperationDelegate -
- (void)autoCompleteTermsDidFetch:(NSDictionary *)fetchInfo
{
    NSString *inputString  = fetchInfo[kFetchedStringKey];
    NSArray *completions = fetchInfo[kFetchedTermsKey];
    [self.autoCompleteSortQueue cancelAllOperations];
    MMAutoCompleteSortOperation *operation = [[MMAutoCompleteSortOperation alloc] initWithDelegate:self incompleteString:inputString possibleCompletions:completions operationType:MMSortUsingStringScore];
    [self.autoCompleteSortQueue addOperation:operation];
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.autoCompleteDelegate respondsToSelector:@selector(autoCompleteSearchBar:willDisplayCell:withCompletionObject:)])
        [self.autoCompleteDelegate autoCompleteSearchBar:self willDisplayCell:cell withCompletionObject:self.autoCompleteSuggestions[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.autoCompleteRowHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MMAutoCompletionObject> autoCompleteObject = self.autoCompleteSuggestions[indexPath.row];
    if(![autoCompleteObject conformsToProtocol:@protocol(MMAutoCompletionObject)]){
        autoCompleteObject = nil;
    }
    
    [self.autoCompleteDelegate autoCompleteSearchBar:self didSelectAutoCompleteObject:autoCompleteObject];
    [self resignFirstResponder];
}


#pragma mark - UITableViewDataSource -
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.autoCompleteSuggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.tableViewCellIdentifier forIndexPath:indexPath];
    [self.autoCompleteDelegate autoCompleteSearchBar:self configureTableViewCell:cell withCompletionObject:self.autoCompleteSuggestions[indexPath.row]];
    return cell;
}

#pragma mark - UISearchBarDelegate -
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self becomeFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self resignFirstResponder];
}

#pragma mark - Events -
- (BOOL)becomeFirstResponder
{
    [self.autoCompleteDelegate presentResultsForAutoCompleteSearchBar:self];
    [self fetchAutoCompleteSuggestions];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [self.autoCompleteDelegate hideResultsForAutoCompleteSearchBar:self];
    self.autoCompleteTableView = nil;
    return [super resignFirstResponder];
}
@end
