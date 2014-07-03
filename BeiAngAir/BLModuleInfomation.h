//
//  BLModuleInfomation.h
//  GeekController
//
//  Created by yang on 12/4/13.
//  Copyright (c) 2013 broadlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLDeviceInfo : NSObject

@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int lock;
@property (nonatomic, assign) uint32_t password;
@property (nonatomic, assign) int terminal_id;
@property (nonatomic, assign) int sub_device;
@property (nonatomic, strong) NSString *key;

//-(NSString *)setMac;

- (id)initWithMAC:(NSString *)mac type:(NSString *)type
             name:(NSString *)name key:(NSString *)key password:(uint32_t)password
       terminal_id:(int)terminal_id sub_device:(int)sub_device lock:(int)lock;
@end

typedef enum BroadLinkProductType
{
    BROADLINK_SP1 = 0,
    BROADLINK_BeiAngAir = 13,
    BROADLINK_TCLAir = 7,
    BROADLINK_RM1 = 10000,
    BROADLINK_SP2 = 10001,
    BROADLINK_RM2 = 10002,
    BROADLINK_ROUTE1 = 10003,
    BROADLINK_A1 = 10004,
}BroadLinkProductType;

@interface WeatherInfo : NSObject

@property (nonatomic, assign) int pm25;
@property (nonatomic, assign) int lowTemp;
@property (nonatomic, assign) int highTemp;
@property (nonatomic, strong) NSString *quality;

@end

/**
 *  Save module information
 */
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

/**
 *  Save module information
 */
@interface BLTimerInfomation : NSObject

@property (nonatomic, assign) long timerID;
@property (nonatomic, assign) long secondCount;         //定时秒数
@property (nonatomic, assign) int switchState;     //开机状态
@property (nonatomic, assign) long secondSince;      //设置时间
@end

@interface BeiAngSendDataInfo : NSObject

//设置开关状态: 00 关机  01 打开
@property (nonatomic, assign) uint8_t switchStatus;
//手动自动状态: 00 手动状态  01 自动状态
@property (nonatomic, assign) uint8_t autoOrHand;
//净化器运行档位状态: 00 0档位 01 1档 0x02 02 2档 03 3档
@property (nonatomic, assign) uint8_t gearState;
//睡眠状态: 00 不在睡眠状态  01睡眠状态
@property (nonatomic, assign) uint8_t sleepState;
//儿童锁状态: 00 不在儿童锁状态 01儿童锁状态
@property (nonatomic, assign) uint8_t childLockState;
@end

@interface BeiAngReceivedDataInfo : NSObject

//设置开关状态: 00 关机  01 打开
@property (nonatomic, assign) uint8_t switchStatus;
//手动自动状态: 00 手动状态  01 自动状态
@property (nonatomic, assign) uint8_t autoOrHand;
//净化器运行档位状态: 00 0档位 01 1档 0x02 02 2档 03 3档
@property (nonatomic, assign) uint8_t gearState;
//睡眠状态: 00 不在睡眠状态  01睡眠状态
@property (nonatomic, assign) uint8_t sleepState;
//儿童锁状态: 00 不在儿童锁状态 01儿童锁状态
@property (nonatomic, assign) uint8_t childLockState;
//设备类型: 01：280B。02：280C.03:车载04:AURA100.
@property (nonatomic, assign) uint8_t deviceType;
//电极运行时间: 第一位为小时数，第二位为分钟数(0x13,0x18:19小时24分钟)
@property (nonatomic, assign) uint8_t runHours;
//电极运行时间: 第一位为小时数，第二位为分钟数(0x13,0x18:19小时24分钟)
@property (nonatomic, assign) uint8_t runMinutes;
//空气质量档位: 01：一档，好。02：二档，中。03：三档，差
@property (nonatomic, assign) uint8_t airQualityGear;
//空气质量原始数据: 数据
@property (nonatomic, assign) uint8_t airQualityData;
//空气质量原始数据: 数据
@property (nonatomic, assign) uint8_t airQualityDataB;
//光照状态: 01：亮，02：昏暗，03：黑
@property (nonatomic, assign) uint8_t lightCondition;
//维护状态: 01：清洗电极，02：需要检查电极状态并断电重启
@property (nonatomic, assign) uint8_t maintenancesState;
//温度: 带符号数：-127~127(0x8c:-12℃,0x12:18℃)
@property (nonatomic, assign) uint8_t temperature;
//湿度: 不带符号数，0~100(0x39:57%)
@property (nonatomic, assign) uint8_t humidity;
@end
