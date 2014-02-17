//
//  CircularProgressView.h
//  AnimatedPaths
//
//  Created by Marc on 1/9/14.
//
//

#import <UIKit/UIKit.h>
#import "MMCircularView.h"

@interface MMCircularProgressView : MMCircularView
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;
@property (nonatomic, assign) float percentage;
@property (nonatomic, assign) float duration;

@property (nonatomic, copy) UIImage *imageIndicator UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *colorProgressStroke UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) NSString *lineJoin UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) NSString *lineCap UI_APPEARANCE_SELECTOR;

- (instancetype)initWithFrame:(CGRect)frame radius:(float)radius minimumValue:(float)minimumValue maximumValue:(float)maximumValue percentage:(float)percentage duration:(float)duration;

- (void)startAnimating;

@end
