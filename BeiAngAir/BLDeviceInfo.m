//
//  BLDeviceInfo.m
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceInfo.h"

@implementation BLDeviceInfo

- (id)initWithMAC:(NSString *)mac type:(NSString *)type name:(NSString *)name key:(NSString *)key password:(uint32_t)password terminal_id:(int)terminal_id sub_device:(int)sub_device lock:(int)lock
{
	self = [super init];
	if (self)
	{
		self.mac = mac;
		self.type = type;
		self.name = name;
		self.key = key;
		self.password = password;
		self.terminal_id = terminal_id;
		self.sub_device = sub_device;
		self.lock = lock;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<mac: %@, type: %@, name: %@, key: %@>", self.mac, self.type, self.name, self.key];
}

@end
