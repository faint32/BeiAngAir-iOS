//
//  BLDeviceInfo.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface BLDeviceInfo : NSObject

@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int lock;
@property (nonatomic, assign) uint32_t password;
@property (nonatomic, assign) int terminal_id;
@property (nonatomic, assign) int sub_device;
@property (nonatomic, strong) NSString *key;

//module
//@property (nonatomic, strong) BLDeviceInfo *info;
//@property (nonatomic, assign) long infoID;//设备在数据库中的id号，关联其他表
@property (nonatomic, assign) float longitude;//经度
@property (nonatomic, assign) float latitude;//纬度
@property (nonatomic, assign) int isNew;
@property (nonatomic, assign) long order;
@property (nonatomic, assign) int switchState;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *cityCode;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *remoteIP;
@property (nonatomic, strong) NSString *qrInfo;

- (id)initWithMAC:(NSString *)mac type:(NSString *)type
			 name:(NSString *)name key:(NSString *)key password:(uint32_t)password
	  terminal_id:(int)terminal_id sub_device:(int)sub_device lock:(int)lock;
- (void)persistence;
- (void)remove;
//+ (instancetype)latestOne;
+ (instancetype)deviceByMAC:(NSString *)MAC;
+ (NSArray *)allDevices;

@end
