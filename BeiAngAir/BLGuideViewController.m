//
//  BLGuideViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 7/14/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLGuideViewController.h"
#import "BLDeviceListViewController.h"
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

@interface BLGuideViewController ()

@property (nonatomic, strong) BLShareViewController *shareViewController;

@end

@implementation BLGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBarHidden = YES;

	UIImage *image = [UIImage imageNamed:@"guide_content_bg"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	scrollView.contentSize = image.size;
	[scrollView addSubview:imageView];
	
	[self.view addSubview:scrollView];
	
	image = [UIImage imageNamed:@"guide_mydevice"];
	UIImage *imageHighlighted = [UIImage imageNamed:@"guide_mydevice_p"];
	UIButton *devicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	devicesButton.frame = CGRectMake(40, 90, image.size.width, image.size.height);
	[devicesButton setImage:image forState:UIControlStateNormal];
	[devicesButton setImage:imageHighlighted forState:UIControlStateHighlighted];
	[devicesButton addTarget:self action:@selector(devices) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview:devicesButton];
	
	image = [UIImage imageNamed:@"guide_myshare"];
	imageHighlighted = [UIImage imageNamed:@"guide_myshare_p"];
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(190, 220, image.size.width, image.size.height);
	[shareButton setImage:image forState:UIControlStateNormal];
	[shareButton setImage:imageHighlighted forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview:shareButton];
	
	image = [UIImage imageNamed:@"guide_myserver"];
	imageHighlighted = [UIImage imageNamed:@"guide_myserver_p"];
	UIButton *serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
	serviceButton.frame = CGRectMake(90, 320, image.size.width, image.size.height);
	[serviceButton setImage:image forState:UIControlStateNormal];
	[serviceButton setImage:imageHighlighted forState:UIControlStateHighlighted];
	[serviceButton addTarget:self action:@selector(service) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview:serviceButton];
	
	image = [UIImage imageNamed:@"guide_myhelp"];
	imageHighlighted = [UIImage imageNamed:@"guide_myhelp_p"];
	UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	helpButton.frame = CGRectMake(80, 440, image.size.width, image.size.height);
	[helpButton setImage:image forState:UIControlStateNormal];
	[helpButton setImage:imageHighlighted forState:UIControlStateHighlighted];
	[helpButton addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
	[scrollView addSubview:helpButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)devices
{
	BLDeviceListViewController *controller = [[BLDeviceListViewController alloc] initWithStyle:UITableViewStyleGrouped];
//	BLDeviceListViewController *controller = [[BLDeviceListViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)share:(id)sender
{
    FrontiaShare *share = [Frontia getShare];
    
    [share registerQQAppId:@"1101505830" enableSSO:YES];
    [share registerWeixinAppId:@"wx45d480ba2f3138c5"];
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
    content.url = @"http://developer.baidu.com/soc/share";
    content.title = @"社会化分享";
    content.description = @"百度社会化分享组件封装了新浪微博、人人网、开心网、腾讯微博、QQ空间和贴吧等平台的授权及分享功能，也支持本地QQ好友分享、微信分享、邮件和短信发送等，同时提供了API接口调用及本地操作界面支持。组件集成简便，风格定制灵活，可轻松实现多平台分享功能。";
    
    
    //    微信朋友，微信朋友圈，qq，qq空间，sina
    NSArray *platforms = @[FRONTIA_SOCIAL_SHARE_PLATFORM_QQ,FRONTIA_SOCIAL_SHARE_PLATFORM_QQFRIEND,FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_TIMELINE,FRONTIA_SOCIAL_PLATFORM_SINAWEIBO];
    
    [share showShareMenuWithShareContent:content
                        displayPlatforms:platforms
          supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait
                       isStatusBarHidden:NO
                        targetViewForPad:sender
                          cancelListener:onCancel
                         failureListener:onFailure
                          resultListener:onResult];
    
    
//	_shareViewController = [[BLShareViewController alloc] initWithNibName:nil bundle:nil];
//	[_shareViewController showActionSheetInView:self.view];
}

- (void)service
{
	//TODO:暂时不做
}

- (void)help
{
	//TODO:安卓版功能为空
}

@end
