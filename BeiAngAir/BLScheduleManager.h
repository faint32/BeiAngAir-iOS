//
//  BLScheduleManager.h
//  BeiAngAir
//
//  Created by zhangbin on 7/28/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLDevice.h"

@interface BLScheduleManager : NSObject

+ (instancetype)shared;
- (NSString *)scheduleNotificationIdentity;
- (void)scheduleOnOrOff:(BOOL)onOrOff afterDelay:(NSTimeInterval)timeInterval MAC:(NSString *)MAC;

@end
