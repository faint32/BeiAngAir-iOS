//
//  BLAppDelegate.h
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLModuleInfomation.h"

@interface BLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray *deviceArray;
@property (strong, nonatomic) ClassAirQualityInfo *airQualityInfoClass;
@property (strong, nonatomic) NSString *cityCodeStrings;

@end

