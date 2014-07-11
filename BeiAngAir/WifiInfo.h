//
//  WifiInfo.h
//  BeiAngAir
//
//  Created by zhangbin on 7/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WifiInfo : NSObject

@property (nonatomic, strong) NSString *SSID;
@property (nonatomic, strong) NSString *password;

- (void)persistence;
+ (instancetype)wifiInfoWithSSID:(NSString *)SSID;

@end
