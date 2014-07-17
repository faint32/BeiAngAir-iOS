//
//  BLShareViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 7/17/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLShareViewController.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

@interface BLShareViewController () <UIActionSheetDelegate, TencentSessionDelegate>

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) TencentOAuth* tencentOAuth;

@end

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
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1101505830" andDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showActionSheetInView:(UIView *)view
{
	_actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"分享", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:@"微信朋友", @"微信朋友圈", @"QQ朋友", nil];
	_actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[_actionSheet showInView:view];
}

#pragma mark - Weixin

- (void)sendMessage:(NSString *)message toWeChat:(BOOL)isShareToFriends
{
	WXWebpageObject *ext = [WXWebpageObject object];
	NSString *URLString = @"http://www.beiangtech.com";
	ext.webpageUrl = URLString;
	WXMediaMessage *wxMediaMessage = [WXMediaMessage message];
	wxMediaMessage.title = message;
	wxMediaMessage.description = NSLocalizedString(@"欢迎使用贝昂空气净化器，实时监控你的空气质量!", nil);
	[wxMediaMessage setThumbImage:[UIImage imageNamed:@"Icon60"]];
	wxMediaMessage.mediaObject = ext;
	SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
	req.bText = NO;
	req.message = wxMediaMessage;
	req.scene = isShareToFriends ? WXSceneTimeline : WXSceneSession;
	[WXApi sendReq:req];
}

- (void)sendTextMessage
{
	QQApiTextObject* txt = [QQApiTextObject objectWithText:@"马化腾指出，过去两年移动互联网有很多开放平台非常成功。事实上到现在来看，发展到现在一年多，最关键的开放平台是能不能真正从用户和经济回报中打造生态链。"];
	SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txt];
	QQApiSendResultCode sent = [QQApiInterface sendReq:req];
	[self handleSendResult:sent];
}


- (void)sendNewsMessage
{
//	NSLog(@"isQQInstalled: %@", [QQApi isQQInstalled] ? @"YES" : @"NO");
//	NSLog(@"isQQSupportApi: %@", [QQApi isQQSupportApi] ? @"YES" : @"NO");
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Icon60"];
	NSData* data = [NSData dataWithContentsOfFile:path];
	NSURL* url = [NSURL URLWithString:@"http://www.163.com"];
	
	QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:@"天公作美伦敦奥运圣火点燃成功 火炬传递开启" description:@"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。" previewImageData:data];
	SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
	QQApiSendResultCode sent = [QQApiInterface sendReq:req];
	[self handleSendResult:sent];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
	switch (sendResult)
	{
		case EQQAPIAPPNOTREGISTED:
		{
			NSLog(@"App未注册");
			break;
		}
		case EQQAPIMESSAGECONTENTINVALID:
		case EQQAPIMESSAGECONTENTNULL:
		case EQQAPIMESSAGETYPEINVALID: {
			NSLog(@"发送参数错误");
			break;
		}
		case EQQAPIQQNOTINSTALLED: {
			UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
			[msgbox show];
			break;
		}
		case EQQAPIQQNOTSUPPORTAPI: {
			UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
			[msgbox show];
			break;
		}
		case EQQAPISENDFAILD: {
			UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
			[msgbox show];
			break;
		}
		default:
			break;
	}
}



#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self sendMessage:NSLocalizedString(@"贝昂空气净化器", nil) toWeChat:NO];//TODO:
	} else if (buttonIndex == 1) {
		[self sendMessage:NSLocalizedString(@"贝昂空气净化器", nil) toWeChat:YES];//TODO:
	} else if (buttonIndex == 2) {
		[self sendTextMessage];
	}
}

#pragma mark - Tencent

- (void)tencentDidNotLogin:(BOOL)cancelled
{
	NSLog(@"No avaiable qq");
}

- (void)tencentDidLogin
{
	
}

- (void)tencentDidNotNetWork
{
	
}

@end
