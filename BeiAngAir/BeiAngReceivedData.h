//
//  BeiAngReceivedDataInfo.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeiAngReceivedData : NSObject

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

- (instancetype)initWithData:(NSArray *)data;

- (NSString *)airQualityDisplayString;

@end
