//
//  NSString+BeiAng.h
//  BeiAngAir
//
//  Created by zhangbin on 7/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BeiAng)

+ (instancetype)citiesCodeString;
+ (instancetype)deviceAvatarPathWithMAC:(NSString *)MAC;
+ (instancetype)phoneNumber;
+ (instancetype)webSiteAddress;
+ (instancetype)stringFromHexString:(NSString *)hexString;
+ (instancetype)hexStringFromString:(NSString *)string;

@end
