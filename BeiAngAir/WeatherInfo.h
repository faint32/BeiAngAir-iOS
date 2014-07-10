//
//  WeatherInfo.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherInfo : NSObject

@property (nonatomic, assign) int pm25;
@property (nonatomic, assign) int lowTemp;
@property (nonatomic, assign) int highTemp;
@property (nonatomic, strong) NSString *quality;

@end
