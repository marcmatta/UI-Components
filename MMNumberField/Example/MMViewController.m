//
//  MMViewController.m
//  test
//
//  Created by Marc on 5/12/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import "MMViewController.h"
#import "MMNumberField.h"

@interface MMViewController ()
@property (weak, nonatomic) IBOutlet MMNumberField *numberField;
@property (weak, nonatomic) IBOutlet MMNumberField *animatedNumberFieldSetter;
- (IBAction)substractOneClicked:(id)sender;
- (IBAction)addOneClicked:(id)sender;
- (IBAction)setValueAnimated:(id)sender;
@end

@implementation MMViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


- (IBAction)substractOneClicked:(id)sender
{
    self.numberField.value -= 1;
}

- (IBAction)addOneClicked:(id)sender
{
    self.numberField.value += 1;
}

- (IBAction)setValueAnimated:(id)sender
{
    [self.numberField setValue:_animatedNumberFieldSetter.value animated:YES];
}
@end
