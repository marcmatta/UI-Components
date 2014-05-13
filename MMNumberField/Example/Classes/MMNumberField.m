//
//  MMNumberField.m
//  test
//
//  Created by Marc on 5/13/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import "MMNumberField.h"
@interface MMNumberField () <UITextFieldDelegate>
@property (nonatomic, strong) NSCharacterSet *invertedNumberSet;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, assign) BOOL isMaximumInitialized;
@property (nonatomic, assign) CFTimeInterval animationStartTime;
@property (nonatomic, assign) BOOL isMinimumInitialized;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSRunLoop *loop;
@property (nonatomic, assign) NSInteger animationStartValue;
@property (nonatomic, assign) NSInteger animationDifference;
@end

static float MMNumberAnimationDuration = 0.5;

@implementation MMNumberField

- (void)dealloc
{
    if (_displayLink)
        [_displayLink removeFromRunLoop:_loop forMode:NSRunLoopCommonModes];
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize
{
    self.delegate = self;
    self.keyboardType = UIKeyboardTypeDecimalPad;

    if (!_isMaximumInitialized){
        self.maximumAllowedValue = NSIntegerMax;
        if (_maximumAllowedValue < _value)
            _value = _maximumAllowedValue;
    }
    
    if (!_isMinimumInitialized){
        self.minimumAllowedValue = NSIntegerMin;
        if (_minimumAllowedValue > _value)
            _value = _minimumAllowedValue;
    }
}

- (void)setMaximumAllowedValue:(NSInteger)maximumAllowedValue
{
    _maximumAllowedValue = maximumAllowedValue;
    _isMaximumInitialized = YES;
    [self.numberFormatter setMaximum:@(maximumAllowedValue)];
}

- (void)setMinimumAllowedValue:(NSInteger)minimumAllowedValue
{
    _minimumAllowedValue = minimumAllowedValue;
    _isMinimumInitialized = YES;
    [self.numberFormatter setMinimum:@(minimumAllowedValue)];
}

- (void)setValue:(NSInteger)value
{
    [self setValue:value animated:NO];
}

- (void)setValue:(NSInteger)value animated:(BOOL)animated
{
    [self initialize];
    
    if (value > _maximumAllowedValue){
        _value = _maximumAllowedValue;
        return;
    }
    
    if (value < _minimumAllowedValue){
        _value = _minimumAllowedValue;
        return;
    }
    self.animationStartValue = _value;
    _animationDifference = value - _value;
    _value = value;
    
    if (_displayLink){
        [_displayLink removeFromRunLoop:_loop forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
    
    if (animated)
    {
        self.animationStartTime = CACurrentMediaTime();
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setTextUsingDisplayLink:)];
        self.loop = [NSRunLoop currentRunLoop];
        [self.displayLink addToRunLoop:_loop forMode:NSRunLoopCommonModes];
    }else
        [self setTextValueFromValue:_value];
}

- (NSCharacterSet *)invertedNumberSet
{
    if (!_invertedNumberSet)
    {
        _invertedNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"-0123456789"] invertedSet];
    }
    
    return _invertedNumberSet;
}

- (NSNumberFormatter *)numberFormatter
{
    if (!_numberFormatter)
    {
        __autoreleasing NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        _numberFormatter = numberFormatter;
    }
    return _numberFormatter;
}

- (void)setTextUsingDisplayLink:(CADisplayLink *)link
{
    if (link)
    {
        float dt = ([link timestamp] - _animationStartTime) / MMNumberAnimationDuration;
        if (dt >= 1.0) {
            [self setTextValueFromValue:self.value];
            [link removeFromRunLoop:_loop forMode:NSRunLoopCommonModes];
            self.displayLink = nil;
            self.loop = nil;
            return;
        }else{
            NSInteger current = self.animationStartValue + self.animationDifference * dt ;
            [self setTextValueFromValue:current];
        }
    }
}

- (void)setTextValueFromValue:(NSInteger)value
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.text = [self.numberFormatter stringFromNumber:@(value)];
    });
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (string.length == 0)
    {
        _value = [self.numberFormatter numberFromString:finalString].integerValue;
        return YES;
    }
    
     if ([finalString isEqualToString:@"-"])
        return YES;
    
    if ([finalString componentsSeparatedByString:@"-"].count > 2)
        return NO;
    else if ([finalString componentsSeparatedByString:@"-"].count > 1 && ![finalString hasPrefix:@"-"])
        return NO;
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:self.invertedNumberSet] componentsJoinedByString:@""];
    BOOL isNumberValid = (([string isEqualToString:filtered]) && [self.numberFormatter numberFromString:finalString]);
    if (isNumberValid)
        _value = [self.numberFormatter numberFromString:finalString].integerValue;
    return isNumberValid;
}
@end
