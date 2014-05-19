//
//  MMViewController.m
//  TerminalApp
//
//  Created by Marc on 5/14/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import "MMTerminalViewController.h"

@interface MMTerminalCommand : NSObject
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *commandString;
+ (MMTerminalCommand *)commandWithString:(NSString *)commandString;
@end

@implementation MMTerminalCommand
+ (MMTerminalCommand *)commandWithString:(NSString *)commandString
{
    __autoreleasing MMTerminalCommand *command = [MMTerminalCommand new];
    command.commandString = commandString;
    command.date = [NSDate date];
    return command;
}

- (NSString *)description
{
    return _commandString;
}
@end

@interface MMTerminalOutput : NSObject
@property (nonatomic, strong) NSString *outputString;
+ (MMTerminalOutput *)outputWithString:(NSString *)outputString;
@end

@implementation MMTerminalOutput

+ (MMTerminalOutput *)outputWithString:(NSString *)outputString
{
    __autoreleasing MMTerminalOutput *output = [MMTerminalOutput new];
    output.outputString = outputString;
    return output;
}

- (NSString *)description
{
    return _outputString;
}

@end

@implementation MMTerminalCell @end

@interface MMTerminalViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *internalTextView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *commands;
@end

static float MinimumTextViewHeight = 33;
static float MaximumTextViewHeight = 100;

@implementation MMTerminalViewController
{
    NSMutableArray *_rowHeightCache;
}

static MMTerminalCell *SizingCell;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - View Life Cycle -
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize the App Logic Controller
    [self.commands addObject:[MMTerminalOutput outputWithString:[self.delegate commandOutput:nil]]];
    self.internalTextView.hidden = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"MMTerminalCell" bundle:Nil] forCellReuseIdentifier:@"Command"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideOrShow:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideOrShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.internalTextView becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetCellHeights)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_rowHeightCache removeAllObjects];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self resetCellHeights];
}

- (void)resetCellHeights
{
    [self.tableView reloadData];
}
#pragma mark - Getters -
- (NSMutableArray *)commands
{
    if (!_commands)
        _commands = [NSMutableArray array];
    return _commands;
}

#pragma mark - Private Methods -
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
            return MinimumTextViewHeight;
        
        return self.internalTextView.contentSize.height;
    }
}

- (void)configureCell:(MMTerminalCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id cmd = self.commands[indexPath.row];
    cell.labelText.text = [cmd description];
    if ([cmd isKindOfClass:[MMTerminalOutput class]])
    {
        cell.labelText.textColor = [UIColor lightTextColor];
        cell.labelIndicator.text = @">> Output";
    }else
    {
        cell.labelText.textColor = [UIColor cyanColor];
        cell.labelIndicator.text = [NSString stringWithFormat:@"[%@]<< Input", [NSDateFormatter localizedStringFromDate:[cmd date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
        cell.labelIndicator.textColor = [UIColor greenColor];
    }
}

#pragma mark - Notifications -
- (void)keyboardWillHideOrShow:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForTextField = [self.internalTextView.superview convertRect:keyboardFrame fromView:nil];
    
    CGFloat newTopLayoutGuide = keyboardFrameForTextField.origin.y - self.constraintHeightInputField.constant;
    
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        weakSelf.constraintTopInputField.constant = newTopLayoutGuide;
    } completion:^(BOOL finished) {
        weakSelf.internalTextView.hidden = NO;
    }];
}

#pragma mark - UITextViewDelegate -
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text isEqualToString:@"\n"] ) {
        NSString *command = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (command.length > 0)
        {
            [self.commands addObject:[MMTerminalCommand commandWithString:command]];
            
            [self.tableView beginUpdates];
            NSMutableArray *indexes = [NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:self.commands.count - 1 inSection:0]];
            
            if ([self.delegate respondsToSelector:@selector(commandOutput:)])
            {
                NSString *output = [self.delegate commandOutput:command];
                if (output)
                {
                    [self.commands addObject:[MMTerminalOutput outputWithString:output]];
                    [indexes addObject:[NSIndexPath indexPathForRow:self.commands.count - 1 inSection:0]];
                }
            }
            
            [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
            
            [self.tableView scrollToRowAtIndexPath:[indexes lastObject] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            textView.text = nil;
            [self textViewDidChange:textView];
            return NO;
        }else
        {
            [self textViewDidChange:textView];
            return YES;
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat initialHeight = self.constraintHeightInputField.constant;
    CGFloat calculatedHeight = [self measureHeight];
    CGFloat height = calculatedHeight>MinimumTextViewHeight?(calculatedHeight<=MaximumTextViewHeight?calculatedHeight:MaximumTextViewHeight):MinimumTextViewHeight;
    CGFloat difference = initialHeight - height;
    
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.constraintTopInputField.constant += difference;
        weakSelf.constraintHeightInputField.constant = height;
    } completion:^(BOOL finished) {
        if (weakSelf.commands.count > 0)
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.commands.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commands.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SizingCell = [[[NSBundle mainBundle] loadNibNamed:@"MMTerminalCell" owner:self options:nil] objectAtIndex:0];
    });
    
    if (!_rowHeightCache)
        _rowHeightCache = [NSMutableArray array];
    
    while (indexPath.row + 1 >_rowHeightCache.count )
        [_rowHeightCache addObject:[NSNull null]];
    
    if (_rowHeightCache[indexPath.row] == [NSNull null])
    {
        [self configureCell:SizingCell atIndexPath:indexPath];
        
        SizingCell.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
        
        CGSize fittingSize = [SizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        _rowHeightCache[indexPath.row] = @(fittingSize.height);
    }
    
    return [_rowHeightCache[indexPath.row] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMTerminalCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"Command" forIndexPath:indexPath];
    [self configureCell:tableViewCell atIndexPath:indexPath];
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[self.tableView indexPathForSelectedRow]])
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
@end
