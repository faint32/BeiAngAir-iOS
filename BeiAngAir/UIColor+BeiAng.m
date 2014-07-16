//
//  UIColor+BeiAng.m
//  BeiAngAir
//
//  Created by zhangbin on 7/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "UIColor+BeiAng.h"

@implementation UIColor (BeiAng)

+ (instancetype)themeBlue
{
	return [UIColor colorWithRed:1/255.0f green:178/255.0f blue:249/255.0f alpha:1.0f];
}

+ (instancetype)colorAirPolluted
{
	return [UIColor colorWithPatternImage:[UIImage imageNamed:@"weather_layout_color_bg.png"]];
}

@end
