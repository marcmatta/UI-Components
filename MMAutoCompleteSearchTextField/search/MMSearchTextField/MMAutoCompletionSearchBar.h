//
//  MMAutoCompletionSearchBar.h
//  search
//
//  Created by Marc on 4/30/14.
//  Inspired By MLPAutoCompleteTextField by Eddy Borja on 12/29/12
//  Original Licence:

/*
Copyright (c) 2013 Mainloop LLC. All rights reserved.
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <UIKit/UIKit.h>
#import "MMAutoCompleteDataSource.h"
#import "MMAutoCompletionDelegate.h"


@interface MMAutoCompletionSearchBar : UISearchBar <UITableViewDataSource, UITableViewDelegate>
@property (strong) IBOutlet id <MMAutoCompleteDataSource> autoCompleteDataSource;
@property (weak) IBOutlet id <MMAutoCompletionDelegate> autoCompleteDelegate;
@property (nonatomic, strong) UITableView *autoCompleteTableView;
@property (nonatomic, strong) NSString *tableViewCellIdentifier; //Default @"Cell"
@property (nonatomic, assign) CGFloat autoCompleteRowHeight; // Default 44

@property (assign) NSTimeInterval autoCompleteFetchRequestDelay; // Default 0.1

- (void)reloadData;
@end
