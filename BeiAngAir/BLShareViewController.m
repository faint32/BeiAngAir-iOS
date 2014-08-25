//
//  BLShareViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 7/17/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLShareViewController.h"
#import <Frontia/FrontiaAuthorization.h>
#import <Frontia/Frontia.h>
#import <Frontia/FrontiaStorage.h>
#import <Frontia/FrontiaStorageDelegate.h>
#import <Frontia/FrontiaPush.h>
#import <Frontia/FrontiaPersonalStorage.h>
#import <Frontia/FrontiaPersonalStorageDelegate.h>
#import <Frontia/FrontiaQuery.h>
#import <Frontia/FrontiaFile.h>
#import <Frontia/FrontiaData.h>
#import <Frontia/FrontiaUser.h>
#import <Frontia/FrontiaRole.h>
#import <Frontia/FrontiaACL.h>

@implementation BLShareViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)shareWithImage:(UIImage *)image
{
	FrontiaShare *share = [Frontia getShare];
	
	[share registerQQAppId:@"1102154446" enableSSO:YES];
	[share registerWeixinAppId:@"wxc8f3dbe24ba8e504"];
	[share registerSinaweiboAppId:@"166856911"];
	
	//授权取消回调函数
	FrontiaShareCancelCallback onCancel = ^(){
		NSLog(@"OnCancel: share is cancelled");
	};
	
	//授权失败回调函数
	FrontiaShareFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
		NSLog(@"OnFailure: %d  %@", errorCode, errorMessage);
	};
	
	//授权成功回调函数
	FrontiaMultiShareResultCallback onResult = ^(NSDictionary *respones){
		NSLog(@"OnResult: %@", [respones description]);
	};
	
	FrontiaShareContent *content = [[FrontiaShareContent alloc] init];
//	content.url = @"http://www.beiangtech.com";
	content.title = @"贝昂空气净化器";
	content.description = @"欢迎使用贝昂空气净化器，实时监控你的空气质量!";
	content.isShareImageToApp = YES;
	content.imageObj = UIImageJPEGRepresentation(image, 1);
	
	//    微信朋友，微信朋友圈，qq，qq空间，sina
	NSArray *platforms = @[FRONTIA_SOCIAL_SHARE_PLATFORM_QQ,FRONTIA_SOCIAL_SHARE_PLATFORM_QQFRIEND,FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_TIMELINE,FRONTIA_SOCIAL_PLATFORM_SINAWEIBO];
	
	[share showShareMenuWithShareContent:content
						displayPlatforms:platforms
		  supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait
					   isStatusBarHidden:NO
						targetViewForPad:nil
						  cancelListener:onCancel
						 failureListener:onFailure
						  resultListener:onResult];
}

@end
