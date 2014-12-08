//
//  BLDeviceQRCodeViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 12/8/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceQRCodeViewController.h"
#import "QREncoder.h"
#import "BLShareViewController.h"

@interface BLDeviceQRCodeViewController ()

@property (readwrite) UIScrollView *scrollView;
@property (readwrite) UIImage *qrcodeImage;
@property (readwrite) BLShareViewController *shareViewController;

@end

@implementation BLDeviceQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"二维码授权";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(share)];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_scrollView];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 30)];
	label.text = @"扫描二维码添加设备";
	label.textAlignment = NSTextAlignmentCenter;
	[_scrollView addSubview:label];
	
	CGFloat qrcodeWidth = 250;
	NSString *path = [NSString stringWithFormat:@"%@%@", @"http://www.airdog.cn/download?id=", _device.ID];
	DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:path];
	_qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeWidth];
	UIImageView *qrcodeImageView = [[UIImageView alloc] initWithImage:_qrcodeImage];
	qrcodeImageView.frame = CGRectMake((self.view.frame.size.width - qrcodeWidth) / 2, 50, qrcodeWidth, qrcodeWidth);
	[_scrollView addSubview:qrcodeImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)share
{
	_shareViewController = [[BLShareViewController alloc] init];
	[_shareViewController shareWithImage:_qrcodeImage];
}

@end
