//
//  BLModuleInfomation.m
//  GeekController
//
//  Created by yang on 12/4/13.
//  Copyright (c) 2013 broadlink. All rights reserved.
//

#import "BLModuleInfomation.h"

@implementation BLDeviceInfo

- (void)dealloc
{
    [super dealloc];
    self.mac = nil;
    self.type = nil;
    self.name = nil;
    self.key = nil;
    self.password = 0;
    self.terminal_id = 0;
    self.sub_device = 0;
    self.lock = 0;
}

- (id)initWithMAC:(NSString *)mac type:(NSString *)type name:(NSString *)name key:(NSString *)key password:(uint32_t)password terminal_id:(int)terminal_id sub_device:(int)sub_device lock:(int)lock
{
    self = [super init];
    if (self)
    {
        self.mac = mac;
        self.type = type;
        self.name = name;
        self.key = key;
        self.password = password;
        self.terminal_id = terminal_id;
        self.sub_device = sub_device;
        self.lock = lock;
    }
    return self;
}

@end


@implementation WeatherInfo

- (void)dealloc
{
    [super dealloc];
    [self setQuality:nil];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.quality = @"";
    }
    
    return self;
}

@end

@implementation BLModuleInfomation
@synthesize city;
@synthesize cityCode;
@synthesize userName;
@synthesize remoteIP;
@synthesize qrInfo;
@synthesize weather;

- (void)dealloc
{
    [super dealloc];
    [self setInfo:nil];
    [self setCity:nil];
    [self setCityCode:nil];
    [self setUserName:nil];
    [self setRemoteIP:nil];
    [self setQrInfo:nil];
    [self setWeather:nil];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.city = @"";
        self.cityCode = @"";
        self.userName = @"";
        self.remoteIP = @"";
        self.qrInfo = @"";
    }
    
    return self;
}

@end

@implementation BLTimerInfomation
@synthesize timerID;
@synthesize secondCount;
@synthesize switchState;
@synthesize secondSince;

- (void)dealloc
{
    [super dealloc];
    [self setTimerID:0];
    [self setSecondCount:0];
    [self setSwitchState:0];
    [self setSecondSince:0];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.timerID = 0;
        self.secondCount = 0;
        self.switchState = 0;
        self.secondSince = 0;
    }
    
    return self;
}
@end

@implementation BeiAngSendDataInfo

@end
@implementation BeiAngReceivedDataInfo

@end