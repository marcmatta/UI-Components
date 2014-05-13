//
//  MMNumberField.h
//  test
//
//  Created by Marc on 5/13/14.
//  Copyright (c) 2014 Marc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMNumberField : UITextField
@property (nonatomic, assign) NSInteger maximumAllowedValue; //default to NSIntegerMax
@property (nonatomic, assign) NSInteger minimumAllowedValue; //default to NSIntegerMin

@property (nonatomic, assign) NSInteger value;

- (void)setValue:(NSInteger)value animated:(BOOL)animated;
@end
