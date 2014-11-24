//
//  ELDevice.h
//  BeiAngAir
//
//  Created by zhangbin on 11/24/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "ZBModel.h"

@interface ELDevice : ZBModel

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *value;

- (BOOL)online;
- (NSString *)deviceName;

@end
