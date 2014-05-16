//
//  MMViewController.h
//  TerminalApp
//
//  Created by Marc on 5/14/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTerminalDelegate.h"
@interface MMTerminalCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelIndicator;
@property (nonatomic, weak) IBOutlet UILabel *labelText;
@end

@interface MMTerminalViewController : UIViewController
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopInputField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightInputField;
@property (nonatomic, weak) IBOutlet id<MMTerminalDelegate>delegate;
@end
