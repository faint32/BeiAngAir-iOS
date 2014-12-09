//
//  BLGuideViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 7/14/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLGuideViewController.h"
#import "BLShareViewController.h"
#import "BLQRCodeViewController.h"
#import "BLSigninViewController.h"
#import "BLAPIClient.h"
#import "BLDeviceListViewController.h"
#import "BLHelpTableViewController.h"

@interface BLGuideViewController ()

@property (nonatomic, strong) BLShareViewController *shareViewController;

@end

@implementation BLGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
	[devicesButton addTarget:self action:@selector(signin) forControlEvents:UIControlEventTouchUpInside];
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)signin {
	if ([[BLAPIClient shared] isSessionValid]) {
		BLDeviceListViewController *deviceListViewController = [[BLDeviceListViewController alloc] initWithStyle:UITableViewStyleGrouped];
		[self.navigationController pushViewController:deviceListViewController animated:YES];
	} else {
		BLSigninViewController *signinViewController = [[BLSigninViewController alloc] initWithNibName:nil bundle:nil];
		[self.navigationController pushViewController:signinViewController animated:YES];
	}
}

- (void)share:(id)sender {
	_shareViewController = [[BLShareViewController alloc] initWithNibName:nil bundle:nil];
	[_shareViewController shareWithImage:[self.view captureIntoImage]];
}

- (void)service {
	BLQRCodeViewController *controller = [[BLQRCodeViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)help {
	BLHelpTableViewController *helpViewController = [[BLHelpTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:helpViewController];
	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

@end
