//
//  BLAirQualityInfo.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLAirQualityInfo : NSObject

@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int sleepState;
@property (nonatomic, assign) int switchState;
@property (nonatomic, assign) BOOL isRefresh;

@end
