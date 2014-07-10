//
//  BeiAngSendDataInfo.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

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
