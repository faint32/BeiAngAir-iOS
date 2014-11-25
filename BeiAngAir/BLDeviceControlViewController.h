//
//  BLAirQualityViewController.h
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELDevice.h"

@interface BLDeviceControlViewController : UIViewController

@property (nonatomic, strong) BeiAngReceivedData *receivedData;
@property (nonatomic, strong) BLDevice *device;
@property (nonatomic, strong) ELDevice *eldevice;

@end
