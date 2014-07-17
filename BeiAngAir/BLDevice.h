//
//  BLDeviceInfo.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLDevice : NSObject

@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int lock;
@property (nonatomic, assign) uint32_t password;
@property (nonatomic, assign) int terminal_id;
@property (nonatomic, assign) int sub_device;
@property (nonatomic, strong) NSString *key;

@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int sleepState;
@property (nonatomic, assign) int switchState;
@property (nonatomic, assign) BOOL isRefresh;

- (id)initWithMAC:(NSString *)mac type:(NSString *)type
			 name:(NSString *)name key:(NSString *)key password:(uint32_t)password
	  terminal_id:(int)terminal_id sub_device:(int)sub_device lock:(int)lock;
- (void)persistence;
- (void)remove;
- (BOOL)hadPersistenced;
+ (instancetype)deviceByMAC:(NSString *)MAC;
+ (NSArray *)allDevices;
- (BOOL)isBeiAngAirDevice;
- (UIImage *)avatar;

@end
