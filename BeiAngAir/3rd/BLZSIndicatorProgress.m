//
//  BLZSIndicatorProgress.m
//  Test_Pro
//
//  Created by milliwave-Zs on 13-7-3.
//
//

#import "BLZSIndicatorProgress.h"

@implementation BLZSIndicatorProgress

@synthesize  percentLayer,innerKDGoal,outerKDGoal;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self setup];
    }
    return self;
}

- (id)init
{
	if ((self = [super init]))
	{
		[self setup];
	}
    
	return self;
}
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    percentLayer = [BLZSProgressLayer layer];
    percentLayer.contentsScale = [UIScreen mainScreen].scale;
    percentLayer.percent = 0;
    percentLayer.frame = self.bounds;
    percentLayer.masksToBounds = NO;
    [percentLayer setNeedsDisplay];
    [self.layer addSublayer:percentLayer];
}

- (void)setInnerKDGoal:(float)inner outerKDGoal:(float)outer
{
    innerKDGoal = inner;
    outerKDGoal = outer;
    [percentLayer setInnerRadius: innerKDGoal outerRadius:outerKDGoal];
    
}

#pragma mark - Custom Getters/Setters
- (void)setPercent:(float)percent maxPercent:(float)maxPercent animated:(BOOL)animated
{
    if (percent > maxPercent)
    {
        float transform;
        transform = maxPercent;
        maxPercent = percent;
        percent = transform;
        
    }
    CGFloat floatPercent = percent / maxPercent;
    floatPercent = MIN(1, MAX(0, floatPercent));
    
    percentLayer.percent = floatPercent;
    [self setNeedsLayout];
    [percentLayer setNeedsDisplay];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
