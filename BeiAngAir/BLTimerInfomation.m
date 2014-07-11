//
//  BLTimerInfomation.m
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLTimerInfomation.h"

#define kTimerInfo @"timerInfo"
#define kTimerID @"timerID"
#define kSecondCount @"secondCount"
#define kSwitchState @"switchState"
#define kSecondSince @"secondSince"

@implementation BLTimerInfomation

- (void)persistence
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	attributes[kTimerID] = @(self.timerID);
	attributes[kSecondCount] = @(self.secondCount);
	attributes[kSwitchState] = @(self.switchState);
	attributes[kSecondSince] = @(self.secondSince);
	
	[[NSUserDefaults standardUserDefaults] setObject:attributes forKey:kTimerInfo];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (instancetype)timerInfomation
{
	NSDictionary *attributes = [[NSUserDefaults standardUserDefaults] objectForKey:kTimerInfo];
	BLTimerInfomation *timerInfomation = [[BLTimerInfomation alloc] init];
	if (attributes) {
		timerInfomation.timerID = [attributes[kTimerID] longValue];
		timerInfomation.secondCount = [attributes[kSecondCount] longValue];
		timerInfomation.switchState = [attributes[kSwitchState] integerValue];
		timerInfomation.secondSince = [attributes[kSecondSince] longValue];
	}
	return timerInfomation;
}

@end
