//
//  BLDeviceInfo.m
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

typedef NS_ENUM(NSUInteger, BroadLinkProductType) {
	BROADLINK_SP1 = 0,
	BROADLINK_BeiAngAir = 13,
	BROADLINK_TCLAir = 7,
	BROADLINK_RM1 = 10000,
	BROADLINK_SP2 = 10001,
	BROADLINK_RM2 = 10002,
	BROADLINK_ROUTE1 = 10003,
	BROADLINK_A1 = 10004
};

#import "BLDeviceInfo.h"

#define kDevices @"devices"
#define kMac @"mac"
#define kType @"type"
#define kName @"name"
#define kLock @"lock"
#define kPassword @"password"
#define kTerminalID @"terminalID"
#define kSubDevice @"subDevice"
#define kKey @"key"

#define kLongitude @"longitude"
#define kLatitude @"latitude"
#define kOrder @"order"
#define kSwitchState @"swtichState"
#define kCity @"city"
#define kCityCode @"cityCode"
#define kUserName @"userName"
#define kRemoteIP @"remoteIP"
#define kQRInfo @"QRInfo"

@implementation BLDeviceInfo

- (id)initWithMAC:(NSString *)mac type:(NSString *)type name:(NSString *)name key:(NSString *)key password:(uint32_t)password terminal_id:(int)terminal_id sub_device:(int)sub_device lock:(int)lock
{
	self = [super init];
	if (self) {
		self.mac = mac;
		self.type = type;
		self.name = name;
		self.key = key;
		self.password = password;
		self.terminal_id = terminal_id;
		self.sub_device = sub_device;
		self.lock = lock;
		
		self.airQualityInfo = [[BLAirQualityInfo alloc] init];
	}
	return self;
}

- (void)persistence
{
	if ([self hadPersistenced]) {
		return;
	}
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	attributes[kMac] = self.mac ?: @"";
	attributes[kType] = self.type ?: @"";
	attributes[kName] = self.name ?: @"";
	attributes[kLock] = @(self.lock);
	attributes[kPassword] = @(self.password);
	attributes[kTerminalID] = @(self.terminal_id);
	attributes[kSubDevice] = @(self.sub_device);
	attributes[kKey] = self.key ?: @"";
	
	attributes[kLongitude] = @(self.longitude);
	attributes[kLatitude] = @(self.latitude);
	attributes[kOrder] = @(self.order);
	attributes[kSwitchState] = @(self.switchState);
	attributes[kCity] = self.city ?: @"";
	attributes[kCityCode] = self.cityCode ?: @"";
	attributes[kUserName] = self.userName ?: @"";
	attributes[kRemoteIP] = self.remoteIP ?: @"";
	attributes[kQRInfo] = self.qrInfo ?: @"";
	
	NSArray *multiAttributes = [[NSUserDefaults standardUserDefaults] objectForKey:kDevices];
	NSMutableArray *new = multiAttributes ? [NSMutableArray arrayWithArray:multiAttributes] : [NSMutableArray array];
	[new addObject:attributes];
	[[NSUserDefaults standardUserDefaults] setObject:new forKey:kDevices];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)remove
{
	if (![self hadPersistenced]) {
		return;
	}
	
	NSArray *multiAttributes = [[NSUserDefaults standardUserDefaults] objectForKey:kDevices];
	NSMutableArray *new = [NSMutableArray array];
	for (int i = 0; i < multiAttributes.count; i++) {
		NSDictionary *attributes = multiAttributes[i];
		if (![attributes[kMac] isEqualToString:self.mac]) {
			[new addObject:attributes];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:new forKey:kDevices];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hadPersistenced
{
	NSArray *multiAttributes = [[NSUserDefaults standardUserDefaults] objectForKey:kDevices];
	__block BOOL hadPersistenced = NO;
	[multiAttributes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *attributes = (NSDictionary *)obj;
		if ([attributes[kMac] isEqualToString:self.mac]) {
			hadPersistenced = YES;
			*stop = YES;
		}
	}];
	return hadPersistenced;
}

+ (NSArray *)allDevices
{
	NSArray *multiAttributes = [[NSUserDefaults standardUserDefaults] objectForKey:kDevices];
	NSMutableArray *devices = [NSMutableArray array];
	for (int i = 0; i < multiAttributes.count; i++) {
		NSDictionary *attributes = multiAttributes[i];
		BLDeviceInfo *device = [[BLDeviceInfo alloc] initWithAttributes:attributes];
		[devices addObject:device];
	}
	return devices;
}

+ (instancetype)deviceByMAC:(NSString *)MAC
{
	NSArray *multiAttributes = [[NSUserDefaults standardUserDefaults] objectForKey:kDevices];
	for (int i = 0; i < multiAttributes.count; i++) {
		NSDictionary *attributes = multiAttributes[i];
		if ([attributes[kMac] isEqualToString:MAC]) {
			return [[BLDeviceInfo alloc] initWithAttributes:attributes];
		}
	}
	return nil;
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
	BLDeviceInfo *device = [[BLDeviceInfo alloc] init];
	device.mac = attributes[kMac];
	device.type = attributes[kType];
	device.name = attributes[kName];
	device.lock = [attributes[kLock] integerValue];
	device.password = [attributes[kPassword] unsignedIntegerValue];
	device.terminal_id = [attributes[kTerminalID] integerValue];
	device.sub_device = [attributes[kSubDevice] integerValue];
	device.key = attributes[kKey];
	
	device.longitude = [attributes[kLongitude] floatValue];
	device.latitude = [attributes[kLatitude] floatValue];
	device.order = [attributes[kOrder] longValue];
	device.switchState = [attributes[kSwitchState] integerValue];
	device.city = attributes[kCity];
	device.cityCode = attributes[kCityCode];
	device.userName = attributes[kUserName];
	device.remoteIP = attributes[kRemoteIP];
	device.qrInfo = attributes[kQRInfo];
	return device;
}

- (BOOL)isBeiAngAirDevice
{
	return [self.type isEqualToString:[NSString stringWithFormat:@"%d", BROADLINK_BeiAngAir]];
}

- (UIImage *)avatar
{
	NSString *path = [NSString deviceAvatarPathWithMAC:self.mac];
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	if (image) {
		return image;
	}
	return [UIImage imageNamed:@"device_icon"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<mac: %@, type: %@, name: %@, key: %@>", self.mac, self.type, self.name, self.key];
}

@end
