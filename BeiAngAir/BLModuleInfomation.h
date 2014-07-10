//
//  BLModuleInfomation.h
//  GeekController
//
//  Created by yang on 12/4/13.
//  Copyright (c) 2013 broadlink. All rights reserved.
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

@interface BLModuleInfomation : NSObject

@property (nonatomic, strong) BLDeviceInfo *info;
@property (nonatomic, assign) long infoID;         //设备在数据库中的id号，关联其他表
@property (nonatomic, assign) float longitude;     //经度
@property (nonatomic, assign) float latitude;      //纬度
@property (nonatomic, assign) int isNew;
@property (nonatomic, assign) long order;
@property (nonatomic, assign) int switchState;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *cityCode;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *remoteIP;
@property (nonatomic, strong) NSString *qrInfo;
@property (nonatomic, strong) WeatherInfo *weather;

@end
