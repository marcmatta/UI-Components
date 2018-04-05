//
//  MMViewController.m
//  search
//
//  Created by Marc on 4/30/14.
//
//

#import "MMViewController.h"
#import "MMAutoCompletionSearchBar.h"
#import "MMPerson.h"

@interface MMViewController () <MMAutoCompleteDataSource, MMAutoCompletionDelegate, UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet MMAutoCompletionSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItemSearch;
@property (strong, nonatomic) UIPopoverController *popoverViewController;
@property (weak, nonatomic) IBOutlet UILabel *labelSelectedValue;
@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)persons
{
    return @[[[MMPerson alloc] initWithName:@"Marc MATTA"],
             [[MMPerson alloc] initWithName:@"Camil Karam"],
             [[MMPerson alloc] initWithName:@"Elise Herro"],
             [[MMPerson alloc] initWithName:@"Pascal Esber"],
             [[MMPerson alloc] initWithName:@"Saoud Haidar"],
             [[MMPerson alloc] initWithName:@"Jad Bou Saleh"],
             [[MMPerson alloc] initWithName:@"Joanne Moussa"],
             [[MMPerson alloc] initWithName:@"Jad Yazbeck"],
             [[MMPerson alloc] initWithName:@"Elie Azar"],
             [[MMPerson alloc] initWithName:@"Dany Rizk"],
             [[MMPerson alloc] initWithName:@"Elie Haddad"],
             [[MMPerson alloc] initWithName:@"Ziad Roumy"],
             [[MMPerson alloc] initWithName:@"Dayana Feghali"]];
}

#pragma mark - MMAutoCompleteDataSource -
- (void)autoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar suggestionForString:(NSString*)string completionHandler:(void (^)(NSArray *dataSource))completionHandler
{
    __weak typeof (self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        
        NSArray *completions = [weakSelf persons];

        completionHandler(completions);
    });
}

#pragma mark - MMAutoCompleteDelegate -
- (void)presentResultsForAutoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar
{
    UITableViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchListController"];
    [tableViewController loadView];
    searchBar.autoCompleteTableView = tableViewController.tableView;
    __autoreleasing UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:tableViewController];
    popover.delegate = self;
    self.popoverViewController = popover;
    [popover presentPopoverFromBarButtonItem:self.barButtonItemSearch permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)hideResultsForAutoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar
{
    if (_popoverViewController)
    {
        [_popoverViewController dismissPopoverAnimated:YES];
        self.popoverViewController = nil;
    }
}

- (void)autoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar didSelectAutoCompleteObject:(id<MMAutoCompletionObject>)completionObject
{
    self.labelSelectedValue.text = [completionObject autoCompletionValue];
}

- (void)autoCompleteSearchBar:(MMAutoCompletionSearchBar *)searchBar configureTableViewCell:(UITableViewCell *)tableViewCell withCompletionObject:(id<MMAutoCompletionObject>)completionObject
{
    tableViewCell.textLabel.text = [completionObject autoCompletionValue];
}

#pragma mark - UIPopoverController -
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverViewController = nil;
    [self.searchBar resignFirstResponder];
}

@end
