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

@interface BLShareViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) UIActionSheet *actionSheet;

@end

@implementation BLShareViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showActionSheetInView:(UIView *)view
{
	_actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"分享", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:@"微信朋友", @"微信朋友圈", nil];
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


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self sendMessage:NSLocalizedString(@"贝昂空气净化器", nil) toWeChat:NO];//TODO:
	} else if (buttonIndex == 1) {
		[self sendMessage:NSLocalizedString(@"贝昂空气净化器", nil) toWeChat:YES];//TODO:
	}
}

@end
