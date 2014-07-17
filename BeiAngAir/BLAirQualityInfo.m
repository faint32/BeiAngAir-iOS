//
//  BLAirQualityInfo.m
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLAirQualityInfo.h"

@implementation BLAirQualityInfo

- (NSString *)description
{
	return [NSString stringWithFormat:@"< hour: %d, minute: %d, sleepState: %d, switchState: %d, isRefresh: %d >", self.hour, self.minute, self.sleepState, self.switchState, self.isRefresh];
}

@end
