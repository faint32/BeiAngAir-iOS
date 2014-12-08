//
//  BLQRScanViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 12/8/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLQRCodeScanViewController.h"
#import "ZBarSDK.h"
#import "BLAPIClient.h"

@interface BLQRCodeScanViewController () <ZBarReaderViewDelegate>

@end

@implementation BLQRCodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"扫描二维码";
	
	ZBarReaderView *readerView = [[ZBarReaderView alloc]init];
	readerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	readerView.readerDelegate = self;
	if (TARGET_IPHONE_SIMULATOR) {
		ZBarCameraSimulator *cameraSimulator = [[ZBarCameraSimulator alloc]initWithViewController:self];
		cameraSimulator.readerView = readerView;
	}
	[self.view addSubview:readerView];
	[readerView start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ZBarReaderViewDelegate

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
	NSString *deviceID = nil;
	for (ZBarSymbol *symbol in symbols) {
		NSString *path = symbol.data;
		NSLog(@"path: %@", path);
		NSString *flag = @"id=";
		NSRange range = [path rangeOfString:flag];
		if (range.location != NSNotFound) {
			deviceID = [path substringFromIndex:range.location + flag.length];
			if (deviceID.length) {
				break;
			}
		}
	}
	if (deviceID.length) {
		[[BLAPIClient shared] authorizeDevice:@([deviceID integerValue]) role:@"user" withBlock:^(NSError *error) {
			[self hideHUD:YES];
			if (!error) {
				NSLog(@"授权成功");
				[self displayHUDTitle:nil message:@"添加成功"];
				[self.navigationController popViewControllerAnimated:YES];
			} else {
				NSLog(@"error: %@", error.userInfo[BL_ERROR_MESSAGE_IDENTIFIER]);
			}
		}];
	}
}

@end
