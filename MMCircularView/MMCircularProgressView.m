//
//  CircularProgressView.m
//  AnimatedPaths
//
//  Created by Marc on 1/9/14.
//
//

#import "MMCircularProgressView.h"

@interface MMCircularProgressView ()
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CALayer *arrowLayer;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSRunLoop *loop;
@property (nonatomic, readonly) float to;

- (void)animateNumber:(CADisplayLink *)link;
@end

@implementation MMCircularProgressView
@dynamic imageIndicator;
@dynamic colorProgressStroke;
@dynamic lineCap;
@dynamic lineJoin;

#pragma mark - init and dealloc -
- (instancetype)initWithFrame:(CGRect)frame radius:(float)radius minimumValue:(float)minimumValue maximumValue:(float)maximumValue percentage:(float)percentage duration:(float)duration
{
    if (self = [super initWithFrame:frame radius:radius])
    {
        _minimumValue = minimumValue;
        _maximumValue = maximumValue;
        _percentage = percentage;
        _duration = duration;
    }
    return self;
}

- (void)dealloc
{
    if (_displayLink)
        [_displayLink removeFromRunLoop:_loop forMode:NSRunLoopCommonModes];
    self.displayLink = nil;
    self.loop = nil;
    self.progressLayer = nil;
    self.arrowLayer = nil;
}

+ (void)initialize
{
    [super initialize];
    
    MMCircularProgressView *appearance = [self appearance];
    [appearance setColorProgressStroke:[UIColor redColor]];
    [appearance setLineCap:kCALineCapRound];
    [appearance setLineJoin:kCALineJoinRound];
    [appearance setImageIndicator:[UIImage imageNamed:@"animated-arrow"]];
}


#pragma mark - Layout -
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_maximumValue <= 0)
        _maximumValue = 100;
    if (_duration <= 0)
        _duration = 0.6;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) radius:self.radius startAngle:-90 * M_PI / 180 endAngle:(360*self.percentage-90) * M_PI / 180 clockwise:YES];
   
    self.progressLayer.frame = self.bounds;
    self.progressLayer.path = path.CGPath;
    self.progressLayer.strokeColor = self.colorProgressStroke.CGColor;
    self.progressLayer.fillColor = nil;
    self.progressLayer.lineWidth = self.strokeLineWidth;
    self.progressLayer.lineJoin = self.lineJoin;
    self.progressLayer.lineCap = self.lineCap;
    
    self.arrowLayer.contentsScale = [UIScreen mainScreen].scale;
    self.arrowLayer.anchorPoint = CGPointMake(0, 0.5);
    
    self.progressLayer.hidden = YES;
    self.arrowLayer.hidden = YES;
    self.label.hidden = YES;
    
    [self startAnimating];
}

#pragma mark - Setters -

- (void)setPercentage:(float)percentage
{
    _percentage = percentage;
    [self setNeedsLayout];
}

- (void)setMinimumValue:(float)minimumValue
{
    _minimumValue = minimumValue;
    if (_maximumValue < minimumValue)
        _maximumValue = minimumValue;
    [self setNeedsLayout];
}

- (void)setMaximumValue:(float)value
{
    _maximumValue = value;
    if (_maximumValue < _minimumValue)
        _minimumValue = _maximumValue;
    [self setNeedsLayout];
}

#pragma mark - Getters -
- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer)
    {
        self.progressLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

- (CALayer *)arrowLayer
{
    if (!_arrowLayer)
    {
        self.arrowLayer = [CALayer layer];
        [self.layer addSublayer:_arrowLayer];
    }
    return _arrowLayer;
}

- (float)to
{
    return (_maximumValue - _minimumValue) * _percentage;
}

#pragma mark - Appearance -
- (UIImage *)imageIndicator
{
    return [UIImage imageWithCGImage:(__bridge CGImageRef)(self.arrowLayer.contents)];
}

- (void)setImageIndicator:(UIImage *)imageIndicator
{
    self.arrowLayer.contents = (id)imageIndicator.CGImage;
    self.arrowLayer.frame = CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - self.radius - self.strokeLineWidth, imageIndicator.size.width, imageIndicator.size.height);
    
}

- (UIColor *)colorProgressStroke
{
    return [UIColor colorWithCGColor:self.progressLayer.strokeColor];
}

- (void)setColorProgressStroke:(UIColor *)colorProgressStroke
{
    self.progressLayer.strokeColor = colorProgressStroke.CGColor;
    [self setNeedsDisplay];
}

- (NSString *)lineCap
{
    return self.progressLayer.lineCap;
}

- (void)setLineCap:(NSString *)lineCap
{
    self.progressLayer.lineCap = lineCap;
    [self setNeedsDisplay];
}

- (NSString *)lineJoin
{
    return self.progressLayer.lineJoin;
}

- (void)setLineJoin:(NSString *)lineJoin
{
    self.progressLayer.lineJoin = lineJoin;
    [self setNeedsDisplay];
}

#pragma mark - Class Methods -
- (void)animateNumber:(CADisplayLink *)link {
    float dt = ([link timestamp] - _startTime) / _duration;
    if (dt >= 1.0) {
        [self setValue:self.to];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }else{
        float current = self.to * dt;
        [self setValue:current];
    }
}

#pragma mark - Animations & Transitions -
- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        self.arrowLayer.hidden = NO;
    }
    
    self.displayLink = nil;
    self.loop = nil;
}

#pragma mark - Public -
- (void)startAnimating
{
    [self.progressLayer removeAllAnimations];
    [self.arrowLayer removeAllAnimations];
    
    self.progressLayer.hidden = NO;
    self.arrowLayer.hidden = NO;
    self.label.hidden = NO;
    
    [CATransaction begin];
    
    CAKeyframeAnimation *strokeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.duration = _duration;
    strokeAnimation.calculationMode = kCAAnimationPaced;
    strokeAnimation.values = @[@(0.0f), @(1.f)];
    strokeAnimation.removedOnCompletion = YES;
    strokeAnimation.delegate = self;
    [self.progressLayer addAnimation:strokeAnimation forKey:@"strokeEnd"];
    
    CAKeyframeAnimation *pencilAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pencilAnimation.path = self.progressLayer.path;
    pencilAnimation.duration = strokeAnimation.duration;
    pencilAnimation.rotationMode = kCAAnimationRotateAuto;
    pencilAnimation.calculationMode = kCAAnimationPaced;
    pencilAnimation.fillMode = kCAFillModeForwards;
    pencilAnimation.removedOnCompletion = NO;
    [self.arrowLayer addAnimation:pencilAnimation forKey:@"position"];
    
    [self setValue:_minimumValue];
    
    if (_displayLink){
        [_displayLink removeFromRunLoop:_loop forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateNumber:)];
    
    self.startTime = CACurrentMediaTime();
    self.loop = [NSRunLoop currentRunLoop];
    [self.displayLink addToRunLoop:_loop forMode:NSRunLoopCommonModes];
    
    [CATransaction commit];
}

@end
