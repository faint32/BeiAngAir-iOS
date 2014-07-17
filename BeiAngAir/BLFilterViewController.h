//
//  BLFilterViewController.h
//  TableAir
//
//  Created by hqb on 14-5-27.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BeiAngReceivedDataInfo.h"

@interface BLFilterViewController : UIViewController

@property (nonatomic, strong) BeiAngReceivedDataInfo *currentAirInfo;
@property (nonatomic, strong) BLDevice *deviceInfo;

@end
