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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bg_g@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    CGRect viewFrame = self.view.frame;
    viewFrame.origin = CGPointZero;
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    [backgroundImageView setImage:image];
    [self.view addSubview:backgroundImageView];
    
    path = [[NSBundle mainBundle] pathForResource:@"return1@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
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
    
//    if (appDelegate.currentAirInfo.motorFailure && appDelegate.currentAirInfo.airSensorFailure)
//    {
//        viewFrame = titleLabel.frame;
//        viewFrame.origin.y += viewFrame.size.height;
//        viewFrame.size = CGSizeMake(self.view.frame.size.width, 32.0f);
//        UILabel *motorLabel = [[UILabel alloc] initWithFrame:viewFrame];
//        [motorLabel setBackgroundColor:[UIColor clearColor]];
//        [motorLabel.layer setBorderColor:RGBA(0x99, 0x99, 0x99, 0.5f).CGColor];
//        [motorLabel.layer setBorderWidth:0.8f];
//        [motorLabel setTextColor:[UIColor redColor]];
//        [motorLabel setFont:[UIFont systemFontOfSize:17.0f]];
//        [motorLabel setText:NSLocalizedString(@"DeviceErrorViewControllerMotorFailed", nil)];
//        [self.view addSubview:motorLabel];
//        
//        viewFrame = motorLabel.frame;
//        viewFrame.origin.y += viewFrame.size.height - 0.8f;
//        UILabel *sensorLabel = [[UILabel alloc] initWithFrame:viewFrame];
//        [sensorLabel setBackgroundColor:[UIColor clearColor]];
//        [sensorLabel.layer setBorderColor:RGBA(0x99, 0x99, 0x99, 0.5f).CGColor];
//        [sensorLabel.layer setBorderWidth:0.8f];
//        [sensorLabel setTextColor:[UIColor redColor]];
//        [sensorLabel setFont:[UIFont systemFontOfSize:17.0f]];
//        [sensorLabel setText:NSLocalizedString(@"DeviceErrorViewControllerAirSensorFailed", nil)];
//        [self.view addSubview:sensorLabel];
//        
//        viewFrame = sensorLabel.frame;
//        viewFrame.origin.y += viewFrame.size.height - 0.8f;
//        UIButton *serviceButton = [[UIButton alloc] initWithFrame:viewFrame];
//        [serviceButton setBackgroundColor:[UIColor clearColor]];
//        [serviceButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
//        [serviceButton setTitleColor:RGB(0x13, 0xb3, 0x5c) forState:UIControlStateNormal];
//        [serviceButton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
//        [serviceButton addTarget:self action:@selector(serviceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:serviceButton];
//    }
//    else if (appDelegate.currentAirInfo.motorFailure)
//    {
//        viewFrame = titleLabel.frame;
//        viewFrame.origin.y += viewFrame.size.height;
//        viewFrame.size = CGSizeMake(self.view.frame.size.width, 32.0f);
//        UILabel *motorLabel = [[UILabel alloc] initWithFrame:viewFrame];
//        [motorLabel setBackgroundColor:[UIColor clearColor]];
//        [motorLabel.layer setBorderColor:RGBA(0x99, 0x99, 0x99, 0.5f).CGColor];
//        [motorLabel.layer setBorderWidth:0.8f];
//        [motorLabel setTextColor:[UIColor redColor]];
//        [motorLabel setFont:[UIFont systemFontOfSize:17.0f]];
//        [motorLabel setText:NSLocalizedString(@"DeviceErrorViewControllerMotorFailed", nil)];
//        [self.view addSubview:motorLabel];
//        
//        viewFrame = motorLabel.frame;
//        viewFrame.origin.y += viewFrame.size.height - 0.8f;
//        UIButton *serviceButton = [[UIButton alloc] initWithFrame:viewFrame];
//        [serviceButton setBackgroundColor:[UIColor clearColor]];
//        [serviceButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
//        [serviceButton setTitleColor:RGB(0x13, 0xb3, 0x5c) forState:UIControlStateNormal];
//        [serviceButton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
//        [serviceButton addTarget:self action:@selector(serviceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:serviceButton];
//    }
//    else if (appDelegate.currentAirInfo.airSensorFailure)
//    {
//        viewFrame = titleLabel.frame;
//        viewFrame.origin.y += viewFrame.size.height;
//        viewFrame.size = CGSizeMake(self.view.frame.size.width, 32.0f);
//        UILabel *sensorLabel = [[UILabel alloc] initWithFrame:viewFrame];
//        [sensorLabel setBackgroundColor:[UIColor clearColor]];
//        [sensorLabel.layer setBorderColor:RGBA(0x99, 0x99, 0x99, 0.5f).CGColor];
//        [sensorLabel.layer setBorderWidth:0.8f];
//        [sensorLabel setTextColor:[UIColor redColor]];
//        [sensorLabel setFont:[UIFont systemFontOfSize:17.0f]];
//        [sensorLabel setText:NSLocalizedString(@"DeviceErrorViewControllerAirSensorFailed", nil)];
//        [self.view addSubview:sensorLabel];
//        
//        viewFrame = sensorLabel.frame;
//        viewFrame.origin.y += viewFrame.size.height - 0.8f;
//        UIButton *serviceButton = [[UIButton alloc] initWithFrame:viewFrame];
//        [serviceButton setBackgroundColor:[UIColor clearColor]];
//        [serviceButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
//        [serviceButton setTitleColor:RGB(0x13, 0xb3, 0x5c) forState:UIControlStateNormal];
//        [serviceButton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
//        [serviceButton addTarget:self action:@selector(serviceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:serviceButton];
//    }
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
