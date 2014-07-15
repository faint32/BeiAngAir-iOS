//
//  ClassAirQualityInfo.m
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "ClassAirQualityInfo.h"

@implementation ClassAirQualityInfo

- (NSString *)description
{
	return [NSString stringWithFormat:@"< cityCode: %@, cityName: %@, weather: %@, temperateStrings: %@, airQualityString: %@, airQualityLevel: %@, pm25: %@ >", self.cityCode, self.cityName, self.weather, self.temperateStrings, self.airQualityString, self.airQualityLevel, self.pm25];
}

@end
