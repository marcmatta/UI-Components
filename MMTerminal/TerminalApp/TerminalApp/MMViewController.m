//
//  MMViewController.m
//  TerminalApp
//
//  Created by Marc on 5/14/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import "MMViewController.h"

@interface MMViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *internalTextView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *commands;
@end

static float MinimumHeight = 33;

@implementation MMViewController
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideOrShow:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideOrShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.internalTextView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.internalTextView becomeFirstResponder];
}

- (NSMutableArray *)commands
{
    if (!_commands)
        _commands = [NSMutableArray array];
    return _commands;
}

- (void)keyboardWillHideOrShow:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForTextField = [self.internalTextView.superview convertRect:keyboardFrame fromView:nil];
    
    CGRect newTextFieldFrame = self.internalTextView.frame;
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
    
    CGRect newTableFrame = self.tableView.frame;
    newTableFrame.size.height -= keyboardFrameForTextField.size.height + MinimumHeight;
    
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        weakSelf.internalTextView.frame = newTextFieldFrame;
        weakSelf.tableView.frame = newTableFrame;
    } completion:^(BOOL finished) {
        weakSelf.internalTextView.hidden = NO;
    }];
}

// Code from apple developer forum - @Steve Krulewitz, @Mark Marszal, @Eric Silverberg
- (CGFloat)measureHeight
{
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        CGRect frame = self.internalTextView.bounds;
        CGSize fudgeFactor;
        // The padding added around the text on iOS6 and iOS7 is different.
        fudgeFactor = CGSizeMake(10.0, 16.0);
        
        frame.size.height -= fudgeFactor.height;
        frame.size.width -= fudgeFactor.width;
        
        NSMutableAttributedString* textToMeasure;
        if(self.internalTextView.attributedText && self.internalTextView.attributedText.length > 0){
            textToMeasure = [[NSMutableAttributedString alloc] initWithAttributedString:self.internalTextView.attributedText];
        }
        else{
            textToMeasure = [[NSMutableAttributedString alloc] initWithString:self.internalTextView.text];
            [textToMeasure addAttribute:NSFontAttributeName value:self.internalTextView.font range:NSMakeRange(0, textToMeasure.length)];
        }
        
        if ([textToMeasure.string hasSuffix:@"\n"])
        {
            [textToMeasure appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName:self.internalTextView.font}]];
        }
        
        // NSAttributedString class method: boundingRectWithSize:options:context is
        // available only on ios7.0 sdk.
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                  context:nil];
        
        return CGRectGetHeight(size) + fudgeFactor.height;
    }
    else
    {
        if (self.internalTextView.text.length == 0)
            return MinimumHeight;
        
        return self.internalTextView.contentSize.height;
    }
}
#pragma mark - UITextViewDelegate -
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] ) {
        if (textView.text.length > 0)
        {
            [self.commands addObject:textView.text];
            [self.tableView beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.commands.count-1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        textView.text = nil;
        [self textViewDidChange:textView];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect frame = self.internalTextView.frame;
    CGFloat height = [self measureHeight];
    CGFloat difference = frame.size.height - height;
    frame.origin.y += difference;
    frame.size.height = height;
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.internalTextView.frame = frame;
    }];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commands.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Command" forIndexPath:indexPath];
    tableViewCell.textLabel.text = self.commands[indexPath.row];
    return tableViewCell;
}
@end
