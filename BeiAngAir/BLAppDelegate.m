//
//  BLAppDelegate.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "BLAppDelegate.h"
#import "SBJson.h"
#import "JSONKit.h"
#import "BLNetwork.h"
#import "ASIHTTPRequest.h"
#import "BLGuideViewController.h"
#import "WXApi.h"

@interface BLAppDelegate ()

@property (nonatomic, strong) BLNetwork *network;

@end

@implementation BLAppDelegate

- (void)initBLLicense
{
    _network = [[BLNetwork alloc] init];
	dispatch_queue_t networkQueue = dispatch_queue_create("BLAppDelegateNetworkQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(networkQueue, ^{
		NSString *license = @"+Y3Y41U+V0tMiadtlZIbLmbFAUyNEQnpQaUHLqDJz7Xlcfks6IXYFkKT7/yKy4e8RCK6EtXcIz9NIfzDPgxK5be3RdBxHkaKwzhvA3ew4jM/D/Md2Bk=";
		NSString *typeLicense = @"B2w12IIQC+pidbD8IOavKTfjpeGbMVRubwNdGEbIn5j43nHKuwgx+/UoASwbcEEM";
		NSDictionary *dictionary = [NSDictionary dictionaryNetworkInitWithLicense:license typeLicense:typeLicense];
        NSData *sendData = [dictionary JSONData];
        NSData *response = [_network requestDispatch:sendData];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        NSString *msg = [[response objectFromJSONData] objectForKey:@"msg"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(code != 0) {
                NSString *title = NSLocalizedString(@"UIAlertViewtitleFailed", nil);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"UIAlertViewOKButton", nil), nil];
                [alertView show];
            }
        });
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initBLLicense];
	
	[WXApi registerApp:WEIXIN_APP_ID];
	
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//	[self handleOpenURL:url];
	return YES;
}

- (void)handleOpenURL:(NSURL *)url
{
//	if ([url.scheme isEqualToString:WEIXIN_APP_ID]) {
//		[[NSNotificationCenter defaultCenter] postNotificationName:DSH_NOTIFICATION_AFTER_WEIXIN_IDENTIFIER object:nil userInfo:@{DSH_OPENURL_USERINFO_KEY : url}];
//	}
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
