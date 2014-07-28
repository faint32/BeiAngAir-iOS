//
//  NSDictionary+BeiAng.m
//  BeiAngAir
//
//  Created by zhangbin on 7/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "NSDictionary+BeiAng.h"

#define kAPIID @"api_id"
#define kCommand @"command"
#define kLicense @"license"
#define kTypeLicense @"type_license"
#define kMAC @"mac"
#define kFormat @"format"
#define kData @"data"
#define kName @"name"
#define kLock @"lock"
#define kPassword @"password"
#define kSSID @"ssid"
#define kBroadLinkV2 @"broadlinkv2"
#define kDST @"dst"
#define kType @"type"
#define kID @"id"
#define kSubDevice @"subdevice"
#define kKey @"key"

@implementation NSDictionary (BeiAng)

+ (instancetype)dictionaryEashConfigWithSSID:(NSString *)SSID password:(NSString *)password
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(10000);
	dictionary[kCommand] = @"easyconfig";
	dictionary[kSSID] = SSID;
	dictionary[kPassword] = password;
	//#warning If your device is v1, this field set 0.
	dictionary[kBroadLinkV2] = @(1);
	dictionary[kDST] = @"";
	return dictionary;
}

+ (instancetype)dictionaryCancelEashConfig
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(10001);
	dictionary[kCommand] = @"cancel_easyconfig";
	return dictionary;
}

+ (instancetype)dictionaryNetworkInitWithLicense:(NSString *)license typeLicense:(NSString *)typeLicense
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kCommand] = @"network_init";
	dictionary[kLicense] = license;
	dictionary[kTypeLicense] = typeLicense;
	return dictionary;
}

+ (instancetype)dictionaryDeviceUpdateWithMAC:(NSString *)MAC name:(NSString *)name lock:(NSNumber *)lock
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(13);
	dictionary[kCommand] = @"device_update";
	dictionary[kMAC] = MAC;
	dictionary[kName] = name;
	dictionary[kLock] = lock;
	return dictionary;
}

+ (instancetype)dictionaryProbeList
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(11);
	dictionary[kCommand] = @"probe_list";
	return dictionary;
}

+ (instancetype)dictionaryDeviceStateWithMAC:(NSString *)MAC
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(16);
	dictionary[kCommand] = @"device_state";
	dictionary[kMAC] = MAC;
	return dictionary;
}

+ (instancetype)dictionaryDeviceDeleteWithMAC:(NSString *)MAC
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(14);
	dictionary[kCommand] = @"device_delete";
	dictionary[kMAC] = MAC;
	return dictionary;
}

+ (instancetype)dictionaryDeviceAddWithMAC:(NSString *)MAC name:(NSString *)name type:(NSString *)type lock:(NSNumber *)lock password:(NSNumber *)password terminalID:(NSNumber *)terminalID subDevice:(NSNumber *)subDevice key:(NSString *)key;
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(12);
	dictionary[kCommand] = @"device_add";
	dictionary[kMAC] = MAC;
	dictionary[kName] = name;
	dictionary[kType] = type;
	dictionary[kLock] = lock;
	dictionary[kPassword] = password;
	dictionary[kID] = terminalID;
	dictionary[kSubDevice] = subDevice;
	dictionary[kKey] = key;
	return dictionary;
}

+ (instancetype)dictionaryPassthroughWithMAC:(NSString *)MAC
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(9000);
	dictionary[kCommand] = @"passthrough";
	dictionary[kMAC] = MAC;
	dictionary[kFormat] = @"bytes";
	NSMutableArray *dataArray = [NSMutableArray array];
	for (int i = 0; i <= 24; i++){
		if(i == 0) [dataArray addObject:@(0xfe)];
		else if(i == 1) [dataArray addObject:@(0x45)];//查询
		else if(i == 23) [dataArray addObject:@(0x00)];
		else if(i == 24) [dataArray addObject:@(0xaa)];
		else [dataArray addObject:@(0x00)];
	}
	dictionary[kData] = dataArray;
	return dictionary;
}

+ (instancetype)dictionaryPassthroughWithMAC:(NSString *)MAC switchStatus:(NSNumber *)switchStatus
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(9000);
	dictionary[kCommand] = @"passthrough";
	dictionary[kMAC] = MAC;
	dictionary[kFormat] = @"bytes";
	NSMutableArray *dataArray = [NSMutableArray array];
	for (int i = 0; i <= 24; i++) {
		if(i == 0) [dataArray addObject:[NSNumber numberWithInt:0xfe]];
		else if(i == 1) [dataArray addObject:@(0x41)];//app控制设备
		else if(i == 4) [dataArray addObject:switchStatus];
		else if(i == 24) [dataArray addObject:@(0xaa)];
		else [dataArray addObject:@(0x00)];
	}
	dictionary[kData] = dataArray;
	return dictionary;
}

+ (instancetype)dictionaryPassthroughWithMAC:(NSString *)MAC switchStatus:(NSNumber *)switchStatus autoOrManual:(NSNumber *)autoOrManual gearState:(NSNumber *)gearState sleepState:(NSNumber *)sleepState childLockState:(NSNumber *)childLockState
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	dictionary[kAPIID] = @(9000);
	dictionary[kCommand] = @"passthrough";
	dictionary[kMAC] = MAC;
	dictionary[kFormat] = @"bytes";
	NSMutableArray *dataArray = [NSMutableArray array];
	for (int i = 0; i <= 24; i++) {
		if(i == 0) [dataArray addObject:[NSNumber numberWithInt:0xfe]];
		else if(i == 1) [dataArray addObject:@(0x41)];
		else if(i == 4) [dataArray addObject:switchStatus];
		else if(i == 5) [dataArray addObject:autoOrManual];
		else if(i == 6) [dataArray addObject:gearState];
		else if(i == 7) [dataArray addObject:sleepState];
		else if(i == 8) [dataArray addObject:childLockState];
		else if(i == 23) [dataArray addObject:@(0x00)];
		else if(i == 24) [dataArray addObject:@(0xaa)];
		else [dataArray addObject:@(0x00)];
	}
	dictionary[kData] = dataArray;
	return dictionary;
}


@end
