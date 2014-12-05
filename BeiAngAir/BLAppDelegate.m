//
//  BLAppDelegate.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BLAppDelegate.h"
#import "BLGuideViewController.h"
#import <Frontia/Frontia.h>
#import "CocoaSecurity.h"

@implementation BLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //初始化Frontia
	NSString *APP_KEY = @"SMT9pXGos5t0ZR7mMlcVMGlx";
	[Frontia initWithApiKey:APP_KEY];
	
	//TODO:先注释掉，影响我听歌了
	//加上代码后，如果你从音乐播放器切换到你的app，你会发现音乐播放器停止播放了。
//    NSError *setCategoryErr = nil;
//    NSError *activationErr  = nil;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryErr];
//    [[AVAudioSession sharedInstance] setActive:YES error: &activationErr];

	BLGuideViewController *controller = [[BLGuideViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:navigationController];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return YES;
}

@end
