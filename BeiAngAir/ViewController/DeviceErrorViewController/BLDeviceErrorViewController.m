//
//  BLDeviceErrorViewController.m
//  TCLAir
//
//  Created by yang on 4/19/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceErrorViewController.h"
#import "GlobalDefine.h"
#import "BLAppDelegate.h"

@interface BLDeviceErrorViewController ()
{
    BLAppDelegate *appDelegate;
}

@end

@implementation BLDeviceErrorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (BLAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    UIImage *image = [UIImage imageNamed:@"bg_g"];
    CGRect viewFrame = self.view.frame;
    viewFrame.origin = CGPointZero;
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    [backgroundImageView setImage:image];
    [self.view addSubview:backgroundImageView];
    
    image = [UIImage imageNamed:@"return1"];
    viewFrame = CGRectZero;
    viewFrame.origin.x = 10.0f;
    viewFrame.size = image.size;
    viewFrame.origin.y = ((IsiOS7Later) ? 20.0f : 0.0f) + (44.0f - image.size.height) * 0.5f;
    UIButton *backButton = [[UIButton alloc] initWithFrame:viewFrame];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = backButton.frame.origin.x + backButton.frame.size.width + 5.0f;
    viewFrame.origin.y = (IsiOS7Later) ? 20.0f : 0.0f;
    viewFrame.size.width = (self.view.frame.size.width - backButton.frame.size.width * 2 - 30.0f);
    viewFrame.size.height = 44.0f;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:NSLocalizedString(@"DeviceErrorViewControllerTitle", nil)];
    [titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:RGB(0xff, 0xff, 0xff)];
    [self.view addSubview:titleLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)backButtonClicked:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)serviceButtonClicked:(UIButton *)button
{
    UIWebView *callWebView = [[UIWebView alloc] init];
    NSURL *url = [NSURL URLWithString:@"tel://4008-123456"];
    [callWebView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:callWebView];
}

@end
