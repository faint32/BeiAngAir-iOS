//
//  BLZSIndicatorProgress.h
//  Test_Pro
//
//  Created by milliwave-Zs on 13-7-3.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BLZSProgressLayer.h"

@interface BLZSIndicatorProgress : UIView

@property (strong, nonatomic) BLZSProgressLayer *percentLayer;
@property (assign, nonatomic) float innerKDGoal;
@property (assign, nonatomic) float outerKDGoal;

- (void)setPercent:(float)percent maxPercent:(float)maxPercent animated:(BOOL)animated;
- (void)setInnerKDGoal:(float)inner outerKDGoal:(float)outer;

@end
