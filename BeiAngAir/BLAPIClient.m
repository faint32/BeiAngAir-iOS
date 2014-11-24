//
//  BLAPIClient.m
//  BeiAngAir
//
//  Created by zhangbin on 11/24/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLAPIClient.h"
#import "CocoaSecurity.h"

NSString * const BL_ERROR_DOMAIN = @"BL_ERROR_DOMAIN";
NSString * const BL_ERROR_MESSAGE_IDENTIFIER = @"BL_ERROR_MESSAGE_IDENTIFIER";
NSString * const EASY_LINK_USER_ID_IDENTIFIER = @"EASY_LINK_USER_ID_IDENTIFIER";
NSString * const EASY_LINK_TOKEN_IDENTIFIER = @"EASY_LINK_TOKEN_IDENTIFIER";
NSString * const EASY_LINK_API_KEY = @"34b9a684f1fd61194026d92b7cf2a11c";
NSString * const EASY_LINK_API_SECRET = @"dc52bdb7601eafb7fa580e000f8d293f";

@interface BLAPIClient ()

@property (readwrite) NSInteger apiRequestCount;

@end

@implementation BLAPIClient

+ (instancetype)shared;
{
	static BLAPIClient *_shared = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *baseURLString = @"http://121.207.243.132/v1/";
		NSURL *url = [NSURL URLWithString:baseURLString];
		_shared = [[BLAPIClient alloc] initWithBaseURL:url];
		NSMutableSet *types = [_shared.responseSerializer.acceptableContentTypes mutableCopy];
		[types addObject:@"text/plain"];
		_shared.responseSerializer.acceptableContentTypes = types;
		_shared.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
	});
	return _shared;
}

- (void)saveUserID:(NSString *)userID {
	if (userID) {
		[[NSUserDefaults standardUserDefaults] setObject:userID forKey:EASY_LINK_USER_ID_IDENTIFIER];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (NSString *)userID {
	NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:EASY_LINK_USER_ID_IDENTIFIER];
	return userID ?: @"";
}

- (void)saveToken:(NSString *)token {
	if (token) {
		[[NSUserDefaults standardUserDefaults] setObject:token forKey:EASY_LINK_TOKEN_IDENTIFIER];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (NSString *)token {
	NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:EASY_LINK_TOKEN_IDENTIFIER];
	return token ?: @"";
}

- (NSString *)dataTOJSONString:(id)object {
	NSString *string = nil;
	NSError *error;
	NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
	if (!data) {
		NSLog(@"dataTOJSONString error: %@", error);
	} else {
		string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return string;
}

- (NSError *)handleResponse:(id)responseObject {
	NSLog(@"responseObject: %@", responseObject);
	NSError *error = nil;
	NSDictionary *result = [responseObject valueForKeyPath:@"result"];
	NSInteger code = [result[@"code"] integerValue];
	if (code != 0 && code != 200) {
		NSString *message = result[@"message"];
		if (!message || [message isEqual:[NSNull null]]) {
			message = NSLocalizedString(@"未知错误", nil);
		}
		error = [NSError errorWithDomain:BL_ERROR_DOMAIN code:1 userInfo:@{BL_ERROR_MESSAGE_IDENTIFIER : message}];
	}
	return error;
}

- (NSDictionary *)addSystemParametersAndForceRequestParametersAsEmptyString:(BOOL)yesOrNo {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"id"] = @(++_apiRequestCount);
	
	NSInteger timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
	CocoaSecurityResult *md5 = [CocoaSecurity md5:[NSString stringWithFormat:@"%@%@%@", EASY_LINK_API_KEY, @(timestamp), EASY_LINK_API_SECRET]];
	NSString *sign = md5.hexLower;
	parameters[@"system"] = @{@"time" : [NSString stringWithFormat:@"%d", timestamp],
							  @"jsonrpc" : @(2.0),
							  @"version" : @(1.0),
							  @"key" : EASY_LINK_API_KEY,
							  @"sign" : sign
							  };
	
	parameters[@"request"] = @{@"token" : yesOrNo ? @"" : [self token],
							   @"user_id" : yesOrNo ? @"" : [self userID],
							   @"info" : @""
							   };
	return parameters;
}

- (void)registerAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSError *error))block {
	NSMutableDictionary *parameters = [[self addSystemParametersAndForceRequestParametersAsEmptyString:YES] mutableCopy];
	parameters[@"method"] = @"register";
	CocoaSecurityResult *md5 = [CocoaSecurity md5:password];
	parameters[@"params"] = @{@"password" : md5.hexLower,
							  @"user_name" : account,
							  };
	[self POST:@"account" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *result = [responseObject valueForKeyPath:@"result"];
		NSError *error = [self handleResponse:responseObject];
		if (!error) {
			[self saveUserID:result[@"data"][@"user_id"]];
		}
		if (block) {
			block(error);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) {
			block(error);
		}
	}];
}

- (void)signinAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSError *error))block {
	NSMutableDictionary *parameters = [[self addSystemParametersAndForceRequestParametersAsEmptyString:YES] mutableCopy];
	parameters[@"method"] = @"login";
	parameters[@"params"] = @{@"password" : @"e10adc3949ba59abbe56e057f20f883e",
							  @"user_name" : @"aric",
							  };
	NSString *JSONString = [self dataTOJSONString:parameters];
	[self POST:@"account" parameters:JSONString success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = [self handleResponse:responseObject];
		NSDictionary *result = [responseObject valueForKeyPath:@"result"];
		if (!error) {
			[self saveUserID:result[@"data"][@"user_id"]];
			[self saveToken:result[@"data"][@"token"]];
		}
		if (block) {
			block(error);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) {
			block(error);
		}
	}];
}

@end
