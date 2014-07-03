//
//  BLAppDelegate.h
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLModuleInfomation.h"

@interface ClassAirQualityInfo : NSObject
//城市
@property (strong, nonatomic) NSString *cityCode;
@property (strong, nonatomic) NSString *cityName;
//天气
@property (strong, nonatomic) NSString *weather;
//温度
@property (strong, nonatomic) NSString *temperateStrings;
//空气质量
@property (strong, nonatomic) NSString *airQualityString;
//空气质量等级
@property (strong, nonatomic) NSString *airQualityLevel;
- (id)init;
@end

#define TOAST_DURATION  0.8f

@interface BLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/*All broadlink module devices.*/
@property (strong, nonatomic) NSMutableArray *deviceArray;
/*Current device*/
@property (strong, nonatomic) BLDeviceInfo *deviceInfo;

@property (strong, nonatomic) BeiAngReceivedDataInfo *currentAirInfo;
@property (strong, nonatomic) ClassAirQualityInfo *airQualityInfoClass;

@property (strong, nonatomic) NSString *cityCodeStrings;

@end

