//
//  BLFMDBSqlite.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLFMDBSqlite.h"
#import "FMDatabase.h"
#import "BLModuleInfomation.h"
//#import "BLModuleClassesDefine.h"
#import <pthread.h>

pthread_mutex_t db_mutex = PTHREAD_MUTEX_INITIALIZER;

@interface BLFMDBSqlite ()
{
    FMDatabase *db;
}

@end

@implementation BLFMDBSqlite

static BLFMDBSqlite *sharedSqlite = nil;

+ (BLFMDBSqlite *)sharedFMDBSqlite
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSqlite = [[BLFMDBSqlite alloc] initWithObj];
    });
    
    return sharedSqlite;
}

- (BOOL)openDb:(FMDatabase *)database
{
    pthread_mutex_lock(&db_mutex);
    return [database open];
}

- (BOOL)closeDb:(FMDatabase *)database
{
    BOOL result = [database close];
    pthread_mutex_unlock(&db_mutex);
    
    return result;
}

- (id)initWithObj
{
    self = [super init];
    if (self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex: 0];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent: @"BroadLinkDeviceList.sqlite"];
        db = [[FMDatabase alloc] initWithPath:dbPath];
        
        if (![self openDb:db])
        {
            NSLog(@"database open failed!");
            return nil;
        }
        [db setShouldCacheStatements:YES];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS broadlink_timer_info(`id` int,`secondCount` long,`switchState` int,`secondSince` long);"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS broadlink_wifi_info(`ssid` varchar(128), `password` varchar(128));"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS deviceTable(`id` long, `userName` varchar(128), `devicePassword` int, `deviceType` short, `deviceMac` varchar(30), `deviceName` varchar(64), `deviceLock` int, `news` int, `publicKey` varchar(32), `terminalId` int, `subDevice` int, `order` long, `switchState` int, `latitude` float, `longitude` float, `city` varchar(64), `cityCode` varchar(64), `netIp` varchar(64), `qrInfo` varchar(64));"];
        [self closeDb:db];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    db = nil;
}

/*定时 information*/
- (BOOL)insertOrUpdateTimerInfo:(BLTimerInfomation *)timerInfomation
{
    BOOL result = NO;
    if (![self openDb:db])
        return result;
    [db setShouldCacheStatements:YES];
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM broadlink_timer_info where `id` = 1"];
    if ([rs next])
    {
        if ([db executeUpdate:@"UPDATE broadlink_timer_info SET `secondCount` = ? , `switchState` = ?,  `secondSince` = ? WHERE `id` = 1", [NSNumber numberWithLong:timerInfomation.secondCount],[NSNumber numberWithInt:timerInfomation.switchState],[NSNumber numberWithLong:timerInfomation.secondSince]])
        {
            result = YES;
        }
    }
    else
    {
        if ([db executeUpdate:@"INSERT INTO broadlink_timer_info(`id`, `secondCount`, `switchState`, `secondSince`) VALUES (1, ?, ?, ?)", [NSNumber numberWithLong:timerInfomation.secondCount],[NSNumber numberWithInt:timerInfomation.switchState],[NSNumber numberWithLong:timerInfomation.secondSince]])
        {
            result = YES;
        }
    }
    
    [self closeDb:db];
    return result;
}

/*定时 information*/
- (BLTimerInfomation *)getSecondCountTimer
{
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    if (![self openDb:db])
    {
        return nil;
    }
    
    [db setShouldCacheStatements:YES];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM broadlink_timer_info"];
    while ([rs next])
    {
        int idString = [rs intForColumn:@"id"];
        long secondCount = [rs longForColumn:@"secondCount"];
        int switchState = [rs intForColumn:@"switchState"];
        long secondSince = [rs longForColumn:@"secondSince"];
        BLTimerInfomation *info = [[BLTimerInfomation alloc] init];
        [info setTimerID:idString];
        [info setSecondCount:secondCount];
        [info setSwitchState:switchState];
        [info setSecondSince:secondSince];
        [infoArray addObject:info];
    }
    [self closeDb:db];
    if(infoArray.count > 0)
        return infoArray[0];
    else
        return nil;
}

/*Get current max info's id*/
- (long)getMaxInfoID
{
    long infoID = 0;
    if (![self openDb:db])
        return infoID;
    [db setShouldCacheStatements:YES];
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM deviceTable ORDER BY `id` DESC;"];
    if ([rs next])
    {
        infoID = [rs longForColumn:@"id"];
    }
    
    [self closeDb:db];
    
    return infoID;
}

/*Get all module's info from database*/
- (NSArray *)getAllModuleInfo
{
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    if (![self openDb:db])
    {
        return nil;
    }
    
    [db setShouldCacheStatements:YES];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM deviceTable"];
    while ([rs next])
    {
        int terminalID = [rs intForColumn:@"terminalId"];
        NSString* deviceType = [NSString stringWithFormat:@"%d",[rs intForColumn:@"deviceType"]];
        int subDevice = [rs intForColumn:@"subDevice"];
        int lock = [rs intForColumn:@"deviceLock"];
        int password = [rs intForColumn:@"devicePassword"];
        NSString *name = [rs stringForColumn:@"deviceName"];
        NSString *mac = [rs stringForColumn:@"deviceMac"];
        NSString *publicKey = [rs stringForColumn:@"publicKey"];
        BLDeviceInfo *baseInfo = [[BLDeviceInfo alloc] initWithMAC:mac type:deviceType name:name key:publicKey password:(uint32_t)password terminal_id:terminalID sub_device:subDevice lock:lock];
        
        BOOL isNew = [rs intForColumn:@"news"];
        float longitude = [rs longForColumn:@"longitude"];
        float latitude = [rs longForColumn:@"latitude"];
        NSString *userName = [rs stringForColumn:@"userName"];
        long order = [rs longForColumn:@"order"];
        long infoID = [rs longForColumn:@"id"];
        int switchState = [rs intForColumn:@"switchState"];
        NSString *city = [rs stringForColumn:@"city"];
        NSString *cityCode = [rs stringForColumn:@"cityCode"];
        NSString *netIP = [rs stringForColumn:@"netIp"];
        NSString *qrInfo = [rs stringForColumn:@"qrInfo"];
        BLModuleInfomation *info = [[BLModuleInfomation alloc] init];
        [info setInfo:baseInfo];
        [info setIsNew:isNew];
        [info setLongitude:longitude];
        [info setLatitude:latitude];
        [info setUserName:userName];
        [info setOrder:order];
        [info setInfoID:infoID];
        [info setSwitchState:switchState];
        [info setCity:city];
        [info setCityCode:cityCode];
        [info setRemoteIP:netIP];
        [info setQrInfo:qrInfo];
        [infoArray addObject:info];
    }
    
    [self closeDb:db];
    return infoArray;
}

/*Insert a new module info into database*/
- (BOOL)insertOrUpdateModuleInfo:(BLModuleInfomation *)info
{
    BOOL result = NO;
    if (![self openDb:db])
        return result;
    
    [db setShouldCacheStatements:YES];
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM deviceTable WHERE `id` = ?", [NSNumber numberWithLong:info.infoID]];
    if ([rs next])
    {
        if ([db executeUpdate:@"UPDATE deviceTable SET `userName` = ?, `devicePassword` = ?, `deviceType` = ?, `deviceMac` = ?, `deviceName` = ?, `deviceLock` = ?, `news` = ?, `publicKey` = ?, `terminalId` = ?, `subDevice` = ?, `order` = ?, `switchState` = ?, `latitude` = ?, `longitude` = ?, `city` = ?, `cityCode` = ?, `netIP` = ?, `qrInfo` = ? WHERE `id` = ?", info.userName, [NSNumber numberWithInt:info.info.password],info.info.type, info.info.mac, info.info.name, [NSNumber numberWithInt:info.info.lock], [NSNumber numberWithInt:info.isNew], info.info.key, [NSNumber numberWithInt:info.info.terminal_id], [NSNumber numberWithInt:info.info.sub_device], [NSNumber numberWithLong:info.order], [NSNumber numberWithInt:info.switchState], [NSNumber numberWithFloat:info.latitude], [NSNumber numberWithFloat:info.longitude], info.city, info.cityCode, info.remoteIP, info.qrInfo, [NSNumber numberWithLong:info.infoID]])
        {
            result = YES;
        }
    }
    else
    {
        if ([db executeUpdate:@"INSERT INTO deviceTable(`id`, `userName`, `devicePassword`, `deviceType`, `deviceMac`, `deviceName`, `deviceLock`, `news`, `publicKey`, `terminalId`, `subDevice`, `order`, `switchState`, `latitude`, `longitude`, `city`, `cityCode`, `netIp`, `qrInfo`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [NSNumber numberWithLong:info.infoID], info.userName, [NSNumber numberWithInt:info.info.password],info.info.type, info.info.mac, info.info.name, [NSNumber numberWithInt:info.info.lock], [NSNumber numberWithInt:info.isNew], info.info.key, [NSNumber numberWithInt:info.info.terminal_id], [NSNumber numberWithInt:info.info.sub_device], [NSNumber numberWithLong:info.order], [NSNumber numberWithInt:info.switchState], [NSNumber numberWithFloat:info.latitude], [NSNumber numberWithFloat:info.longitude], info.city, info.cityCode, info.remoteIP, info.qrInfo])
        {
            result = YES;
        }
    }
    
    [self closeDb:db];
    return result;
}

/*Get all module's info from database*/
- (BLModuleInfomation *)getModuleInfoByMac:(NSString *)stringMac
{
    BLModuleInfomation *info = [[BLModuleInfomation alloc] init];
    if (![self openDb:db])
    {
        return nil;
    }
    
    [db setShouldCacheStatements:YES];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM deviceTable WHERE `deviceMac` = ?", stringMac];
    while ([rs next])
    {
        int32_t terminalID = [rs intForColumn:@"terminalId"];
        NSString* deviceType = [NSString stringWithFormat:@"%d",[rs intForColumn:@"deviceType"]];
        uint16_t subDevice = [rs intForColumn:@"subDevice"];
        uint8_t lock = [rs intForColumn:@"deviceLock"];
        int password = [rs intForColumn:@"devicePassword"];
        NSString *name = [rs stringForColumn:@"deviceName"];
        NSString *mac = [rs stringForColumn:@"deviceMac"];
        NSString *publicKey = [rs stringForColumn:@"publicKey"];
        BLDeviceInfo *baseInfo = [[BLDeviceInfo alloc] initWithMAC:mac type:deviceType name:name key:publicKey password:password terminal_id:terminalID sub_device:subDevice lock:lock];
        
        BOOL isNew = [rs intForColumn:@"news"];
        float longitude = [rs longForColumn:@"longitude"];
        float latitude = [rs longForColumn:@"latitude"];
        NSString *userName = [rs stringForColumn:@"userName"];
        long order = [rs longForColumn:@"order"];
        long infoID = [rs longForColumn:@"id"];
        int switchState = [rs intForColumn:@"switchState"];
        NSString *city = [rs stringForColumn:@"city"];
        NSString *cityCode = [rs stringForColumn:@"cityCode"];
        NSString *netIP = [rs stringForColumn:@"netIp"];
        NSString *qrInfo = [rs stringForColumn:@"qrInfo"];
        
        [info setInfo:baseInfo];
        [info setIsNew:isNew];
        [info setLongitude:longitude];
        [info setLatitude:latitude];
        [info setUserName:userName];
        [info setOrder:order];
        [info setInfoID:infoID];
        [info setSwitchState:switchState];
        [info setCity:city];
        [info setCityCode:cityCode];
        [info setRemoteIP:netIP];
        [info setQrInfo:qrInfo];
    }
    
    [self closeDb:db];
    return info;
}

/*Delete module's info from database*/
- (BOOL)deleteModuleInfo:(BLModuleInfomation *)info
{
    BOOL result = NO;
    if (![self openDb:db])
        return result;
    [db setShouldCacheStatements:YES];
    if ([db executeUpdate:@"DELETE FROM deviceTable WHERE `deviceMac` = ? AND `id` = ?", info.info.mac, [NSNumber numberWithLong:info.infoID]])
    {
        result = YES;
    }
    
    [self closeDb:db];
    return result;
}

@end
