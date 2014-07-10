//
//  BLAppDelegate.h
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLModuleInfomation.h"

#define TOAST_DURATION  0.8f

@interface BLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/*All broadlink module devices.*/
@property (strong, nonatomic) NSMutableArray *deviceArray;
//@property (strong, nonatomic) BLDeviceInfo *deviceInfo;
//@property (strong, nonatomic) BeiAngReceivedDataInfo *currentAirInfo;
@property (strong, nonatomic) ClassAirQualityInfo *airQualityInfoClass;

@property (strong, nonatomic) NSString *cityCodeStrings;

@end

