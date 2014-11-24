//
//  BLAPIClient.h
//  BeiAngAir
//
//  Created by zhangbin on 11/24/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface BLAPIClient : AFHTTPRequestOperationManager

+ (instancetype)shared;

- (void)registerAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSString *userID, NSError *error))block;

- (void)signinAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSString *userID, NSString *token, NSError *error))block;

@end
