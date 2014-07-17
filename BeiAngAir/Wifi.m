//
//  WifiInfo.m
//  BeiAngAir
//
//  Created by zhangbin on 7/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "Wifi.h"

#define kWIFIs @"wifis"

@implementation Wifi

- (void)persistence
{
	if (self.SSID && self.password) {
		NSDictionary *wifis = [[NSUserDefaults standardUserDefaults] objectForKey:kWIFIs];
		NSMutableDictionary *new = wifis ? [NSMutableDictionary dictionaryWithDictionary:wifis] : [NSMutableDictionary dictionary];
		new[self.SSID] = self.password;
		[[NSUserDefaults standardUserDefaults] setObject:new forKey:kWIFIs];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

+ (instancetype)wifiWithSSID:(NSString *)SSID
{
	NSDictionary *wifis = [[NSUserDefaults standardUserDefaults] objectForKey:kWIFIs];
	if (wifis) {
		if (wifis[SSID]) {
			Wifi *wifi = [[Wifi alloc] init];
			wifi.SSID = SSID;
			wifi.password = wifis[SSID];
			return wifi;
		}
	}
	return nil;
}

@end
