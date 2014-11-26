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
		[types addObject:@"text/html"];
		_shared.responseSerializer.acceptableContentTypes = types;
		_shared.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
	});
	return _shared;
}

- (BOOL)isSessionValid {
	return [self userID].length > 0;
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

- (NSDictionary *)addSystemParametersRequestEmpty:(BOOL)empty signUserID:(BOOL)signIncludingUserID {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"id"] = @(++_apiRequestCount);
	
	NSInteger timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
	NSString *sign = nil;
	sign = [self signWithTimestamp:timestamp signUserID:signIncludingUserID];
	parameters[@"system"] = @{@"time" : [NSString stringWithFormat:@"%d", timestamp],
							  @"jsonrpc" : @(2.0),
							  @"version" : @(1.0),
							  @"key" : EASY_LINK_API_KEY,
							  @"sign" : sign
							  };
	
	parameters[@"request"] = @{@"token" : empty ? @"" : [self token],
							   @"user_id" : empty ? @"" : [self userID]
							   };
	return parameters;
}

- (NSString *)signWithTimestamp:(NSInteger)timestamp signUserID:(BOOL)signIncludingUserID {
	NSMutableString *string = [NSMutableString stringWithFormat:@"%@%@%@", EASY_LINK_API_KEY, @(timestamp), EASY_LINK_API_SECRET];
	if (signIncludingUserID) {
		string = [NSMutableString stringWithFormat:@"%@%@%@%@%@", EASY_LINK_API_KEY, @(timestamp), [self userID], [self token], EASY_LINK_API_SECRET];
	}
	CocoaSecurityResult *md5 = [CocoaSecurity md5:string];
	return md5.hexLower;
}

- (void)registerAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSError *error))block {
	NSMutableDictionary *parameters = [[self addSystemParametersRequestEmpty:YES signUserID:NO] mutableCopy];
	parameters[@"method"] = @"register";
	CocoaSecurityResult *md5 = [CocoaSecurity md5:password];
	parameters[@"params"] = @{@"password" : md5.hexLower,
							  @"user_name" : account,
							  };
	NSString *JSONString = [self dataTOJSONString:parameters];
	[self POST:@"account" parameters:JSONString success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = [self handleResponse:responseObject];
		if (block) block(error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) block(error);
	}];
}

- (void)signinAccount:(NSString *)account password:(NSString *)password withBlock:(void (^)(NSError *error))block {
	NSMutableDictionary *parameters = [[self addSystemParametersRequestEmpty:YES signUserID:NO] mutableCopy];
	parameters[@"method"] = @"login";
	CocoaSecurityResult *md5 = [CocoaSecurity md5:password];
	parameters[@"params"] = @{@"password" : md5.hexLower,
							  @"user_name" : account,
							  };
	NSString *JSONString = [self dataTOJSONString:parameters];
	[self POST:@"account" parameters:JSONString success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = [self handleResponse:responseObject];
		NSDictionary *result = [responseObject valueForKeyPath:@"result"];
		if (!error) {
			[self saveUserID:result[@"data"][@"user_id"]];
			[self saveToken:result[@"data"][@"token"]];
		}
		if (block) block(error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) block(error);
	}];
}

- (void)getBindWithBlock:(void (^)(NSArray *multiAttributes, NSError *error))block {
	NSMutableDictionary *parameters = [[self addSystemParametersRequestEmpty:NO signUserID:YES] mutableCopy];
	parameters[@"method"] = @"getBind";
	parameters[@"params"] = @{@"user_id" : [self userID]};
	NSString *JSONString = [self dataTOJSONString:parameters];
	[self POST:@"homer" parameters:JSONString success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = [self handleResponse:responseObject];
		NSDictionary *result = [responseObject valueForKeyPath:@"result"];
		NSArray *multiAttributes = nil;
		if (!error) {
			multiAttributes = result[@"data"];
		}
		if (block) block(multiAttributes, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) block(nil, error);
	}];
}

- (void)getDeviceStatus:(NSNumber *)deviceID withBlock:(void (^)(NSDictionary *attributes, NSError *error))block {
	NSMutableDictionary *parameters = [[self addSystemParametersRequestEmpty:NO signUserID:YES] mutableCopy];
	parameters[@"method"] = @"getDeviceStatus";
	parameters[@"params"] = @{@"ndevice_id" : deviceID, @"ndevice_sn" : @""};
							  
	NSString *JSONString = [self dataTOJSONString:parameters];
	[self POST:@"homer" parameters:JSONString success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = [self handleResponse:responseObject];
		NSDictionary *result = [responseObject valueForKeyPath:@"result"];
		NSDictionary *attributes = nil;
		if (!error) {
			attributes = result[@"data"][0];
		}
		if (block) block(attributes, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) block(nil, error);
	}];
}

- (void)command:(NSNumber *)deviceID value:(NSString *)value withBlock:(void (^)(NSString *value, NSError *error))block {
	NSMutableDictionary *parameters = [[self addSystemParametersRequestEmpty:NO signUserID:YES] mutableCopy];
	parameters[@"method"] = @"command";
	parameters[@"params"] = @{@"ndevice_id" : deviceID, @"ndevice_sn" : @"", @"command" : value};
	
	NSString *JSONString = [self dataTOJSONString:parameters];
	NSLog(@"json: %@", JSONString);
	[self POST:@"homer" parameters:JSONString success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSLog(@"response object: %@", responseObject);
		NSError *error = [self handleResponse:responseObject];
		NSDictionary *result = [responseObject valueForKeyPath:@"result"];
		NSString *value = nil;
		if (!error) {
			value = result[@"data"][@"reply"];
		}
		if (block) block(value, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (block) block(nil, error);
	}];
}

@end
