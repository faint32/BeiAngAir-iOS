//
//  BLFilterViewController.h
//  TableAir
//
//  Created by hqb on 14-5-27.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomViewController.h"
#import "BeiAngReceivedDataInfo.h"

@interface BLFilterViewController : CustomViewController

@property (nonatomic, strong) BeiAngReceivedDataInfo *currentAirInfo;
@property (nonatomic, strong) BLDeviceInfo *deviceInfo;

@end
