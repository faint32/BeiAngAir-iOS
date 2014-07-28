//
//  NSDictionary+BeiAng.h
//  BeiAngAir
//
//  Created by zhangbin on 7/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BeiAng)

+ (instancetype)dictionaryEashConfigWithSSID:(NSString *)SSID password:(NSString *)password;
+ (instancetype)dictionaryCancelEashConfig;
+ (instancetype)dictionaryNetworkInitWithLicense:(NSString *)license typeLicense:(NSString *)typeLicense;
+ (instancetype)dictionaryDeviceUpdateWithMAC:(NSString *)MAC name:(NSString *)name lock:(NSNumber *)lock;
+ (instancetype)dictionaryProbeList;
+ (instancetype)dictionaryDeviceStateWithMAC:(NSString *)MAC;
+ (instancetype)dictionaryDeviceDeleteWithMAC:(NSString *)MAC;
+ (instancetype)dictionaryDeviceAddWithMAC:(NSString *)MAC name:(NSString *)name type:(NSString *)type lock:(NSNumber *)lock password:(NSNumber *)password terminalID:(NSNumber *)terminalID subDevice:(NSNumber *)subDevice key:(NSString *)key;
+ (instancetype)dictionaryPassthroughWithMAC:(NSString *)MAC;
+ (instancetype)dictionaryPassthroughWithMAC:(NSString *)MAC switchStatus:(NSNumber *)switchStatus;
+ (instancetype)dictionaryPassthroughWithMAC:(NSString *)MAC switchStatus:(NSNumber *)switchStatus autoOrManual:(NSNumber *)autoOrManual gearState:(NSNumber *)gearState sleepState:(NSNumber *)sleepState childLockState:(NSNumber *)childLockState;

@end
