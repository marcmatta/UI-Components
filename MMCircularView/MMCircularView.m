//
//  CircularView.m
//  AnimatedPaths
//
//  Created by Marc on 1/10/14.
//
//

#import "MMCircularView.h"
@interface MMCircularView ()
{
    UIColor *_colorDetails;
    UIColor *_colorUnits;
    UIColor *_colorValue;
    UIFont *_fontDetails;
    UIFont *_fontUnits;
    UIFont *_fontValue;
    NSUInteger _flipUnitValue;
}
@property (nonatomic, strong) CAShapeLayer *fullCircleLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *textValue;

- (CGRect)drawingRect;
- (void)displayValue;
@end

@implementation MMCircularView

@dynamic fontDetails;
@dynamic fontUnits;
@dynamic fontValue;

@dynamic colorDetails;
@dynamic colorUnits;
@dynamic colorValue;

@dynamic colorStroke;
@dynamic colorFill;

@dynamic strokeLineWidth;

@dynamic flipUnitValue;

#pragma mark - init & dealloc -
- (id)initWithFrame:(CGRect)frame radius:(float)radius
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _radius = radius;
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonSetup];
    }
    return self;
}

- (void)dealloc
{
    self.fullCircleLayer = nil;
    self.label = nil;
}

#pragma mark - Setup =

- (void)commonSetup
{
    self.clipsToBounds = YES;
}

+ (void)initialize
{
    if (![self isSubclassOfClass:[MMCircularView class]])
        return;
    
    MMCircularView * appearance = [self appearance];
    [appearance setColorDetails:[UIColor blackColor]];
    [appearance setColorUnits:[UIColor blackColor]];
    [appearance setColorValue:[UIColor blackColor]];
    [appearance setColorStroke:[UIColor grayColor]];
    [appearance setColorFill:nil];
    [appearance setStrokeLineWidth:5];
    [appearance setFontDetails:[UIFont systemFontOfSize:10]];
    [appearance setFontUnits:[UIFont systemFontOfSize:10]];
    [appearance setFontValue:[UIFont boldSystemFontOfSize:14]];
    [appearance setFlipUnitValue:NO];
}

#pragma mark - Layout -
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_radius > 0)
    {
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) radius:_radius startAngle:0 endAngle:2*M_PI clockwise:YES];
        
        self.fullCircleLayer.frame = self.bounds;
        self.fullCircleLayer.path = circlePath.CGPath;
        self.fullCircleLayer.strokeColor = self.colorStroke.CGColor;
        self.fullCircleLayer.fillColor = self.colorFill.CGColor;
        self.fullCircleLayer.lineWidth = self.strokeLineWidth;
        
        self.label.frame = [self drawingRect];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        
        if (_textValue)
            [self displayValue];
    }
}

#pragma mark - Getters =
- (CAShapeLayer *)fullCircleLayer
{
    if (!_fullCircleLayer)
    {
        self.fullCircleLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_fullCircleLayer];
    }
    return _fullCircleLayer;
}

- (UILabel *)label
{
    if (!_label)
    {
        _label = [[UILabel alloc] initWithFrame:[self drawingRect]];
        [_label setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_label];
    }
    
    return _label;
}

#pragma mark - Setters -
- (void)setRadius:(float)radius
{
    _radius = radius;
    [self setNeedsLayout];
}

- (void)setDetails:(NSString *)details
{
    _details = details;
    if (_label)
        [self displayValue];
}

#pragma mark - Public -
- (void)setValue:(float)progress
{
    _textValue = progress<1 && progress>0?[NSString stringWithFormat:@"%.2f", progress]:[NSString stringWithFormat:@"%.f", progress];
    
    if (_label)
        [self displayValue];
}

#pragma mark - UIAppearance -
- (UIColor *)colorFill
{
    return [UIColor colorWithCGColor:self.fullCircleLayer.fillColor];
}

- (void)setColorFill:(UIColor *)colorFill
{
    self.fullCircleLayer.fillColor = colorFill.CGColor;
    [self setNeedsDisplay];
}

- (UIColor *)colorStroke
{
    return [UIColor colorWithCGColor:self.fullCircleLayer.strokeColor];
}

- (void)setColorStroke:(UIColor *)colorStroke
{
    self.fullCircleLayer.strokeColor = colorStroke.CGColor;
    [self setNeedsDisplay];
}

- (UIColor *)colorDetails
{
    return _colorDetails;
}

- (void)setColorDetails:(UIColor *)colorDetails
{
    _colorDetails = [colorDetails copy];
    if (_label)
        [self displayValue];
}

- (UIColor *)colorUnits
{
    return _colorUnits;
}

- (void)setColorUnits:(UIColor *)colorUnits
{
    _colorUnits = [colorUnits copy];
    if (_label)
        [self displayValue];
}

- (UIColor *)colorValue
{
    return _colorValue;
}

- (void)setColorValue:(UIColor *)colorValue
{
    _colorValue = [colorValue copy];
    if (_label)
        [self displayValue];
}

- (UIFont *)fontDetails
{
    return _fontDetails;
}

- (void)setFontDetails:(UIFont *)fontDetails
{
    _fontDetails = [fontDetails copy];
    if (_label)
        [self displayValue];
}

- (UIFont *)fontUnits
{
    return _fontUnits;
}

- (void)setFontUnits:(UIFont *)fontUnits
{
    _fontUnits = [fontUnits copy];
    if (_label)
        [self displayValue];
}

- (UIFont *)fontValue
{
    return _fontValue;
}

- (void)setFontValue:(UIFont *)fontValue
{
    _fontValue = [fontValue copy];
    if (_label)
        [self displayValue];
}

- (NSUInteger)flipUnitValue
{
    return _flipUnitValue;
}

- (void)setFlipUnitValue:(NSUInteger)flipUnitValue
{
    _flipUnitValue = flipUnitValue;
    if (_label)
        [self displayValue];
}

- (CGFloat)strokeLineWidth
{
    return self.fullCircleLayer.lineWidth;
}

- (void)setStrokeLineWidth:(CGFloat)lineWidth
{
    self.fullCircleLayer.lineWidth = lineWidth;
    [self setNeedsDisplay];
}

#pragma mark - Class Methods -

- (CGRect)drawingRect
{
    return CGRectMake(CGRectGetMidX(self.bounds)-_radius, CGRectGetMidY(self.bounds)-_radius, 2*_radius, 2*_radius);
}

- (BOOL)isInitialized
{
    return _colorDetails && _colorValue && _colorUnits && _fontDetails && _fontValue && _fontUnits;
}

- (void)setTextValue:(NSString *)textValue
{
    _textValue = textValue;
    if (_label)
        [self displayValue];
}

- (void)displayValue
{
    if ([self isInitialized])
    {
        
        NSString *textValue = _textValue ? :@"";
        NSString *units = _units ? :@"";
        NSString *details = _details ? :@"";
        
        NSString *text = [NSString stringWithFormat:@"%@ %@%@", _flipUnitValue==NO?textValue:units,_flipUnitValue==NO?units:textValue, details.length > 0?[NSString stringWithFormat:@"\n%@", details]:@""];

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range;
        
        if (textValue.length > 0)
        {
            range = [text rangeOfString:self.textValue];
            [attributedString addAttribute:NSFontAttributeName value:self.fontValue range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:self.colorValue range:range];
        }
        if (units.length > 0) {
            range = [text rangeOfString:self.units];
            [attributedString addAttribute:NSFontAttributeName value:self.fontUnits range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:self.colorUnits range:range];
        }
        
        if (details.length > 0) {
            range = [text rangeOfString:self.details];
            [attributedString addAttribute:NSFontAttributeName value:self.fontDetails range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:self.colorDetails range:range];
        }
        [self.label setClipsToBounds:YES];
        [self.label setAttributedText:attributedString];
    }
}

@end
