//
//  BLDeviceQRCodeViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 12/8/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceQRCodeViewController.h"
#import "QREncoder.h"

@interface BLDeviceQRCodeViewController ()

@property (readwrite) UIScrollView *scrollView;

@end

@implementation BLDeviceQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"二维码授权";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(share)];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_scrollView];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30)];
	label.text = @"扫描二维码添加设备";
	[_scrollView addSubview:label];
	
	CGFloat qrcodeWidth = 250;
	NSString *path = [NSString stringWithFormat:@"%@%@", @"http://www.airdog.cn/download?id=", _device.ID];
	DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:path];
	UIImage *qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeWidth];
	UIImageView *qrcodeImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
	qrcodeImageView.frame = CGRectMake((self.view.frame.size.width - qrcodeWidth) / 2, 50, qrcodeWidth, qrcodeWidth);
	[_scrollView addSubview:qrcodeImageView];
	
	
//	//the qrcode is square. now we make it 250 pixels wide
//	int qrcodeImageDimension = 250;
//	
//	//the string can be very long
//	NSString* aVeryLongURL = @"http://thelongestlistofthelongeststuffatthelongestdomainnameatlonglast.com/";
//	
//	//first encode the string into a matrix of bools, TRUE for black dot and FALSE for white. Let the encoder decide the error correction level and version
//	DataMatrix* qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:aVeryLongURL];
//	
//	//then render the matrix
//	UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
//	
//	//put the image into the view
//	UIImageView* qrcodeImageView = [[UIImageView alloc] initWithImage:qrcodeImage];
//	CGRect parentFrame = self.view.frame;
//	CGRect tabBarFrame = self.tabBarController.tabBar.frame;
//	
//	//center the image
//	CGFloat x = (parentFrame.size.width - qrcodeImageDimension) / 2.0;
//	CGFloat y = (parentFrame.size.height - qrcodeImageDimension - tabBarFrame.size.height) / 2.0;
//	CGRect qrcodeImageViewFrame = CGRectMake(x, y, qrcodeImageDimension, qrcodeImageDimension);
//	[qrcodeImageView setFrame:qrcodeImageViewFrame];
//	
//	//and that's it!
//	[self.view addSubview:qrcodeImageView];
//	[qrcodeImageView release];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)share {
	
}

@end
