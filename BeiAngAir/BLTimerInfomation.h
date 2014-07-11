//
//  BLTimerInfomation.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLTimerInfomation : NSObject

@property (nonatomic, assign) long timerID;
@property (nonatomic, assign) long secondCount;//定时秒数
@property (nonatomic, assign) int switchState;//开机状态
@property (nonatomic, assign) long secondSince;//设置时间

- (void)persistence;
+ (instancetype)timerInfomation;

@end
