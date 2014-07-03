//
//  BLZSProgressLayer.h
//  Test_Pro
//
//  Created by milliwave-Zs on 13-7-3.
//
//

#import <QuartzCore/QuartzCore.h>

@interface BLZSProgressLayer : CALayer

@property (nonatomic) CGFloat percent;
@property (assign, nonatomic) float innerRadius;
@property (assign, nonatomic) float outerRadius;

-(void)setInnerRadius:(float)inner outerRadius:(float)outer;

@end
