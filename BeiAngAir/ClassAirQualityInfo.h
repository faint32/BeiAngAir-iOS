//
//  ClassAirQualityInfo.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassAirQualityInfo : NSObject

@property (strong, nonatomic) NSString *cityCode;
@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *weather;
@property (strong, nonatomic) NSString *temperateStrings;
@property (strong, nonatomic) NSString *airQualityString;
@property (strong, nonatomic) NSString *airQualityLevel;
@property (strong, nonatomic) NSString *pm25;
@property (strong, nonatomic) NSString *airQualityColorHexString;

@end
