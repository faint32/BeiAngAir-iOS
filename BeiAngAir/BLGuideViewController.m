//
//  BLGuideViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 7/14/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLGuideViewController.h"
#import "BLDeviceListViewController.h"

@interface BLGuideViewController ()

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
	[shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
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
	BLDeviceListViewController *controller = [[BLDeviceListViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)share
{
	
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
