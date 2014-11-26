//
//  BLDeviceInfoEditViewController.h
//  TCLAir
//
//  Created by yang on 4/15/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELDevice.h"

@interface BLDeviceEditViewController : UIViewController

@property (nonatomic, strong) BLDevice *device;
@property (nonatomic, strong) ELDevice *eldevice;

@end
