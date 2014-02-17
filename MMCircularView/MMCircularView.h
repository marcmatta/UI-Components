//
//  CircularView.h
//  AnimatedPaths
//
//  Created by Marc on 1/10/14.
//
//

#import <UIKit/UIKit.h>

@interface MMCircularView : UIView
@property (nonatomic, assign) float radius;
@property (nonatomic, strong) NSString *units;
@property (nonatomic, strong) NSString *details;

@property (nonatomic, copy) UIFont *fontValue UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIFont *fontDetails UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIFont *fontUnits UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *colorValue UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *colorDetails UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *colorUnits UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *colorStroke UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *colorFill UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat strokeLineWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSUInteger flipUnitValue UI_APPEARANCE_SELECTOR;

@property (nonatomic, readonly) UILabel *label;

- (void)setValue:(float)value;
- (void)setTextValue:(NSString *)textValue;
- (id)initWithFrame:(CGRect)frame radius:(float)radius;

@end
