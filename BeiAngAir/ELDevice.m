//
//  ELDevice.m
//  BeiAngAir
//
//  Created by zhangbin on 11/24/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "ELDevice.h"
#import "CocoaSecurity.h"

@implementation ELDevice

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
	self = [super initWithAttributes:attributes];
	if (self) {
		_status = [NSString stringWithString:attributes[@"devicestatus"]];
		_ID = attributes[@"ndevice_id"];
		_nickname = [NSString stringWithString:attributes[@"nick_name"]];
		_role = [NSString stringWithString:attributes[@"role"]];
		_value = [NSString stringWithString:attributes[@"value"]];
	}
	return self;
}

- (BOOL)isOnline {
	return [_status isEqualToString:@"online"];
}

- (uint8_t *)dataBuffer {
	CocoaSecurityDecoder *decoder = [[CocoaSecurityDecoder alloc] init];
	NSData *data = [decoder base64:_value];
	uint8_t *dataBuffer = (uint8_t *)[data bytes];
	return dataBuffer;
}

- (NSString *)deviceName {
	//if (!_value) return;//TODO: get from user defaults
	uint8_t *dataBuffer = [self dataBuffer];
	uint8_t flag = dataBuffer[3];//第4位表示设备类型
	NSDictionary *names = @{@(1) : @"280B",
							@(2) : @"280E",
							@(3) : @"CAR",
							@(4) : @"AURA100",
							@(5) : @"JY300",
							@(6) : @"JY500",
							@(8) : @"JY300S",
							@(160) : @"Airdog",
							@(80) : @"TAir"
							};
	return names[@(flag)];
}

- (UIImage *)avatar {
	NSString *imageName = @"item_icon_default";
	
	NSDictionary *names = @{
							@"280E" : @"item_icon_280e",
							@"CAR" : @"item_icon_car",
							@"JY300" : @"item_icon_jy300",
							@"JY300S" : @"item_icon_jy300",
							@"Airdog" : @"item_icon_airdog",
							@"AURA100" : @"item_icon_desktop"
							};
	
	NSString *name = names[[self deviceName]];
	if (name) {
		imageName = name;
	}
	return [UIImage imageNamed:imageName];
}

- (NSString *)displayStatus {
	if ([self isOnline]) {
		return NSLocalizedString(@"设备正在运行", nil);
	}
	return NSLocalizedString(@"设备不在线", nil);
}

- (NSString *)displayName {
	return [NSString stringWithFormat:@"%@(%@)", NSLocalizedString(@"贝昂", nil), [self deviceName]];
}

- (NSNumber *)hours {
	if (!_value) return nil;
	uint8_t *dataBuffer = [self dataBuffer];
	uint8_t flag = dataBuffer[9];//第10位表示小时数
	return @(flag);
}

- (NSNumber *)minutes {
	if (!_value) return nil;
	uint8_t *dataBuffer = [self dataBuffer];
	uint8_t flag = dataBuffer[10];//第11位表示分钟数
	return @(flag);
}

- (uint8_t)flagAtIndex:(NSInteger)index {
	if (!_value) return 0;
	uint8_t *dataBuffer = [self dataBuffer];
	uint8_t flag = dataBuffer[index];
	return flag;
}

- (BOOL)isOn {
	return [self flagAtIndex:4] > 0;
}

- (BOOL)isAutoOn {
	return [self flagAtIndex:5] > 0;
}

- (BOOL)isSleepOn {
	return [self flagAtIndex:7] > 0;
}

- (BOOL)isChildLockOn {
	return [self flagAtIndex:8] > 0;
}

- (NSString *)displayTVOC {
	uint8_t flag = [self flagAtIndex:18];
	NSString *quanlity = NSLocalizedString(@"差", nil);
	if (flag == 0) {
		quanlity = NSLocalizedString(@"优", nil);
	} else if (flag == 1) {
		quanlity = NSLocalizedString(@"良", nil);
	}
	return [NSString stringWithFormat:@"TVOC %@", quanlity];
}

- (NSString *)displayPM25 {
	uint8_t flag = [self flagAtIndex:13];//12, 13
	NSString *quanlity = NSLocalizedString(@"优", nil);
	if (flag >= 200) {
		quanlity = NSLocalizedString(@"严重", nil);
	} else if (flag >= 150) {
		quanlity = NSLocalizedString(@"差", nil);
	} else if (flag >= 100) {
		quanlity = NSLocalizedString(@"中", nil);
	} else if (flag >= 50) {
		quanlity = NSLocalizedString(@"良", nil);
	}
	return [NSString stringWithFormat:@"室内 PM2.5 %dug/m³ %@", flag, quanlity];
}

@end
