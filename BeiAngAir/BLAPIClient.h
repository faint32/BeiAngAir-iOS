//
//  BLAPIClient.h
//  BeiAngAir
//
//  Created by zhangbin on 11/24/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

extern NSString * const BL_ERROR_MESSAGE_IDENTIFIER;

@interface BLAPIClient : AFHTTPRequestOperationManager

+ (instancetype)shared;
- (BOOL)isSessionValid;
- (NSString *)userID;
- (void)registerAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSError *error))block;

- (void)signinAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSError *error))block;

- (void)getBindWithBlock:(void (^)(NSArray *multiAttributes, NSError *error))block;
- (void)getDeviceStatus:(NSNumber *)deviceID withBlock:(void (^)(NSDictionary *attributes, NSError *error))block;
- (void)command:(NSNumber *)deviceID value:(NSString *)value withBlock:(void (^)(NSString *value, NSError *error))block;
- (void)getBindResultWithBlock:(void (^)(BOOL newDeviceFound, NSError *error))block;
- (void)updateAuthorize:(NSNumber *)deviceID role:(NSString *)role nickename:(NSString *)nickname withBlock:(void (^)(NSError *error))block;
- (void)unbindDevice:(NSNumber *)deviceID withBlock:(void (^)(NSError *error))block;
- (void)authorizeDevice:(NSNumber *)deviceID role:(NSString *)role withBlock:(void (^)(NSError *error))block;
- (void)getDeviceData:(NSNumber *)deviceID withBlock:(void (^)(BOOL validForReset, NSError *error))block;
- (void)resetDevice:(NSNumber *)deviceID withBlock:(void (^)(NSError *error))block;

@end
