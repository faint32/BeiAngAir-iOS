//
//  BLFMDBSqlite.h
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLModuleInfomation;
@class BLTimerInfomation;

@interface BLFMDBSqlite : NSObject

+ (BLFMDBSqlite *)sharedFMDBSqlite;


/*Module information*/
- (long)getMaxInfoID;
- (NSArray *)getAllModuleInfo;
- (BOOL)insertOrUpdateModuleInfo:(BLModuleInfomation *)info;
- (BLModuleInfomation *)getModuleInfoByMac:(NSString *)stringMac;
- (BOOL)deleteModuleInfo:(BLModuleInfomation *)info;
/*WiFi information*/
- (BOOL)insertOrUpdateWiFiInfoWithSSID:(NSString *)ssid password:(NSString *)password;
- (NSString *)getPasswordBySSID:(NSString *)ssid;

/*定时 information*/
- (BOOL)insertOrUpdateTimerInfo:(BLTimerInfomation *)timerInfomation;
- (BLTimerInfomation *)getSecondCountTimer;

@end
