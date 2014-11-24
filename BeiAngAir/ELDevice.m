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

- (BOOL)online {
	return [_status isEqualToString:@"online"];
}

- (NSString *)deviceName {
	CocoaSecurityDecoder *decoder = [[CocoaSecurityDecoder alloc] init];
	NSData *data = [decoder base64:_value];
	uint8_t *dataBuffer = (uint8_t *)[data bytes];
	int flag = dataBuffer[3];//第三位表示设备类型
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
@end
