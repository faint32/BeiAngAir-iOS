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

- (void)registerAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSError *error))block;

- (void)signinAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSError *error))block;

@end
