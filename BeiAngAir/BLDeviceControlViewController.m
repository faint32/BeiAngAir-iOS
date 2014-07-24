//
//  BLAirQualityViewController.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceControlViewController.h"
#import "GlobalDefine.h"
#import "BLAppDelegate.h"
#import "Toast+UIView.h"
#import "BLFilterViewController.h"
#import "JSONKit.h"
#import "BLAboutViewController.h"
#import "SBJson.h"
#import "MMProgressHUD.h"
#import "Toast+UIView.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BLNetwork.h"
#import "Weather.h"
#import "BLShareViewController.h"

@interface BLDeviceControlViewController () <UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, assign) dispatch_queue_t httpQueue;
@property (nonatomic, assign) dispatch_queue_t networkQueue;
@property (nonatomic, strong) BLNetwork *networkAPI;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *airQualityLabel;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) UIButton *handOrAutoButton;
@property (nonatomic, strong) UIButton *childLockButton;
@property (nonatomic, strong) UIButton *sleepButton;
@property (nonatomic, strong) UILabel *weatherLabel;
@property (nonatomic, strong) UILabel *leftTimerLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) Weather *weather;
@property (nonatomic, strong) BLShareViewController *shareViewController;

@end

@implementation BLDeviceControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_logo"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_weather = [[Weather alloc] init];
    _networkAPI = [[BLNetwork alloc] init];
    _networkQueue = dispatch_queue_create("BLAirQualityViewCtrollerNetworkQueue", DISPATCH_QUEUE_SERIAL);
    _httpQueue = dispatch_queue_create("BLHttpQueue", DISPATCH_QUEUE_SERIAL);
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager setDistanceFilter:500.0f];
    [_locationManager startUpdatingLocation];

	self.view.backgroundColor = [UIColor greenColor];
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(10, 20, 0, 20);
	
	CGRect viewFrame = CGRectZero;
	viewFrame.origin.x = 20;
	viewFrame.origin.y = 70;
    viewFrame.size.width = self.view.frame.size.width - viewFrame.origin.x * 2;
    viewFrame.size.height = 80;
    _weatherLabel = [[UILabel alloc] initWithFrame:viewFrame];
	_weatherLabel.numberOfLines = 0;
    [_weatherLabel setBackgroundColor:[UIColor clearColor]];
    [_weatherLabel setTextColor:[UIColor whiteColor]];
    [_weatherLabel setFont:[UIFont systemFontOfSize:17.f]];
	[self.view addSubview:_weatherLabel];
	

	UIImage *shareImage = [UIImage imageNamed:@"Share"];
	viewFrame.origin.x = self.view.frame.size.width - shareImage.size.width - edgeInsets.right;
	viewFrame.origin.y = 90;
	viewFrame.size = shareImage.size;
	
	_shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_shareButton.frame = viewFrame;
	_shareButton.showsTouchWhenHighlighted = YES;
	[_shareButton setImage:shareImage forState:UIControlStateNormal];
	[_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_shareButton];
    
    //底部视图
    viewFrame.origin.x =  0;
	viewFrame.origin.y = 145;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = self.view.frame.size.height - viewFrame.origin.y;
	
    UIView *bottomView = [[UIView alloc] initWithFrame:viewFrame];
    [bottomView.layer setMasksToBounds:YES];
    [bottomView.layer setCornerRadius:10.f];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    
    //空气质量指数
    _airQualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, edgeInsets.top, self.view.frame.size.width, 40)];
    [_airQualityLabel setBackgroundColor:[UIColor clearColor]];
	_airQualityLabel.numberOfLines = 0;
    [_airQualityLabel setTextColor:[UIColor blackColor]];
    [_airQualityLabel setFont:[UIFont systemFontOfSize:15.f]];
	_airQualityLabel.textAlignment = NSTextAlignmentCenter;
	_airQualityLabel.text = [NSString stringWithFormat:@"%@\n%@ %@", NSLocalizedString(@"贝昂", nil), NSLocalizedString(@"室内PM2.5", nil), [_receivedData airQualityDisplayString] ?: @"良"];
    [bottomView addSubview:_airQualityLabel];
	
	//风速
	UIImage *image = [UIImage imageNamed:@"wind"];
	viewFrame.origin.x = edgeInsets.left;
	viewFrame.origin.y = edgeInsets.top + 20;
	viewFrame.size = CGSizeMake(image.size.width, image.size.height);
	UIButton *speedButton = [[UIButton alloc] initWithFrame:viewFrame];
	[speedButton setBackgroundColor:[UIColor clearColor]];
	[speedButton setImage:image forState:UIControlStateNormal];
	[speedButton addTarget:self action:@selector(speedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	[bottomView addSubview:speedButton];
	
    //定时任务
	UIImage *timeImage = [UIImage imageNamed:@"time"];
    viewFrame.origin.x =  self.view.frame.size.width - timeImage.size.width - edgeInsets.left;
    viewFrame.origin.y = edgeInsets.top + 20;
    viewFrame.size = timeImage.size;
    UIButton *timerButton = [[UIButton alloc] initWithFrame:viewFrame];
    [timerButton setBackgroundColor:[UIColor clearColor]];
    [timerButton setImage:timeImage forState:UIControlStateNormal];
    [timerButton addTarget:self action:@selector(timerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:timerButton];
	
	CGSize buttonSize = CGSizeMake(110, 110);
	viewFrame.origin.x =  (self.view.frame.size.width - buttonSize.width) / 2.f;
	viewFrame.origin.y = timerButton.frame.origin.y + timerButton.frame.size.height + 15.f;
	viewFrame.size = buttonSize;
	
    _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_switchButton setFrame:viewFrame];
	[_switchButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self deviceOn:self.receivedData.switchStatus];
    [_switchButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_switchButton];
	
	CGSize titleSize = CGSizeZero;
	buttonSize = CGSizeMake(47, 47 + 15);
	viewFrame.origin.x = edgeInsets.left;
	viewFrame.origin.y = CGRectGetMaxY(_switchButton.frame);
	viewFrame.size = buttonSize;
	UIFont *font = [UIFont systemFontOfSize:13];
	
    _handOrAutoButton  = [UIButton buttonWithType:UIButtonTypeCustom];
	[_handOrAutoButton setFrame:viewFrame];
	_handOrAutoButton.titleLabel.font = font;
	[_handOrAutoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self deviceAutoOn:self.receivedData.autoOrHand];
	[_handOrAutoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -buttonSize.width, - buttonSize.height, 0)];
	titleSize = _handOrAutoButton.titleLabel.frame.size;
	[_handOrAutoButton setImageEdgeInsets:UIEdgeInsetsMake(-titleSize.height, 0, 0, -titleSize.width)];
	_handOrAutoButton.contentMode = UIViewContentModeCenter;
	
    [_handOrAutoButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_handOrAutoButton];

	viewFrame.origin.x =  (self.view.frame.size.width - buttonSize.width) / 2.f;
	viewFrame.origin.y = _handOrAutoButton.frame.origin.y + _handOrAutoButton.frame.size.height * 2.f / 3.f;
	
	_sleepButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_sleepButton setFrame:viewFrame];
	_sleepButton.titleLabel.font = font;
	[_sleepButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self deviceSleepOn:self.receivedData.sleepState];
	[_sleepButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -buttonSize.width, - buttonSize.height, 0)];
	titleSize = _sleepButton.titleLabel.frame.size;
	[_sleepButton setImageEdgeInsets:UIEdgeInsetsMake(-titleSize.height, 0, 0, -titleSize.width)];
	_sleepButton.contentMode = UIViewContentModeCenter;
    [_sleepButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_sleepButton];

	viewFrame.origin.x = self.view.frame.size.width - buttonSize.width - edgeInsets.top;
	viewFrame.origin.y = _handOrAutoButton.frame.origin.y;

    _childLockButton  = [UIButton buttonWithType:UIButtonTypeCustom];
	[_childLockButton setFrame:viewFrame];
	_childLockButton.titleLabel.font = font;
	[_childLockButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self deviceChildLockOn:self.receivedData.childLockState];
	[_childLockButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -buttonSize.width, - buttonSize.height, 0)];
	titleSize = _childLockButton.titleLabel.frame.size;
	[_childLockButton setImageEdgeInsets:UIEdgeInsetsMake(-titleSize.height, 0, 0, -titleSize.width)];
	_childLockButton.contentMode = UIViewContentModeCenter;
	[_childLockButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_childLockButton];
	
    viewFrame.origin.x =  0;
    viewFrame.origin.y = bottomView.frame.size.height - 40;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = 20;
	
    _leftTimerLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [_leftTimerLabel setBackgroundColor:[UIColor clearColor]];
    [_leftTimerLabel setTextColor:[UIColor blackColor]];
    [_leftTimerLabel setTextAlignment:NSTextAlignmentCenter];
    [_leftTimerLabel setNumberOfLines:1];
    [bottomView addSubview:_leftTimerLabel];
	
	[self refreshDevice];
}

- (void)refreshWeather
{
	NSLog(@"refreshWeather: %@", _weather);
	_weatherLabel.text = [NSString stringWithFormat:@"%@ %@\n室外 PM:2.5 %@ %@", _weather.cityName, _weather.temperateStrings, _weather.pm25, _weather.airQualityString];
	if([_weather.airQualityLevel isEqualToString:@"4"]) {
		self.view.backgroundColor = [UIColor colorAirPolluted];
	} else {
		self.view.backgroundColor = [UIColor greenColor];
	}
}

- (void)deviceOn:(BOOL)on
{
	NSString *onOrOff = on ? @"power_on" : @"power_off";
	NSString *highlighted = on ? @"power_on_press" : @"power_off_press";
	[_switchButton setImage:[UIImage imageNamed:onOrOff] forState:UIControlStateNormal];
	[_switchButton setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
	_switchButton.selected = on;
}

- (void)deviceAutoOn:(BOOL)on
{
	NSString *onOrOff = on ? @"auto_on" : @"hand_on";
	NSString *highlighted = on ? @"auto_on_press" : @"hand_on_press";
	[_handOrAutoButton setImage:[UIImage imageNamed:onOrOff] forState:UIControlStateNormal];
	[_handOrAutoButton setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
	_handOrAutoButton.selected = on;
	NSString *title = on ? NSLocalizedString(@"Automatic", nil) : NSLocalizedString(@"Manual", nil);
	[_handOrAutoButton setTitle:title forState:UIControlStateNormal];
}

- (void)deviceSleepOn:(BOOL)on
{
	NSString *onOrOff = on ? @"night_on" : @"night_off";
	NSString *highlighted = on ? @"night_on_press" : @"night_off_press";
	[_sleepButton setImage:[UIImage imageNamed:onOrOff] forState:UIControlStateNormal];
	[_sleepButton setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
	_sleepButton.selected = on;
	NSString *title = on ? NSLocalizedString(@"SleepOn", nil) : NSLocalizedString(@"SleepOff", nil);
	[_sleepButton setTitle:title forState:UIControlStateNormal];
}

- (void)deviceChildLockOn:(BOOL)on
{
	NSString *onOrOff = on ? @"lock_on" : @"lock_off";
	NSString *highlighted = on ? @"lock_on_press" : @"lock_off_press";
	[_childLockButton setImage:[UIImage imageNamed:onOrOff] forState:UIControlStateNormal];
	[_childLockButton setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
	_childLockButton.selected = on;
	NSString *title = on ? NSLocalizedString(@"TheChildLock", nil) : NSLocalizedString(@"TheChildLockOff", nil);
	[_childLockButton setTitle:title forState:UIControlStateNormal];
}


- (void)refreshDevice
{
	NSDictionary *dictionary = [NSDictionary dictionaryPassthroughWithMAC:_device.mac];
	NSData *sendData = [dictionary JSONData];
	NSData *response = [_networkAPI requestDispatch:sendData];
	int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
	if (code == 0) {
		dispatch_async(_networkQueue, ^{
			NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
			BeiAngReceivedData *receivedData = [[BeiAngReceivedData alloc] initWithData:array];
			NSLog(@"BeiAngReceivedDataInfo: %@", receivedData);
			NSLog(@"airdisplay: %@", [receivedData airQualityDisplayString]);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				//[self performSelector:@selector(refreshDevice) withObject:nil afterDelay:3.0];
			});
		});
	}
}
//弹出视图
-(void)popUpView:(UIButton *)button
{
    //背景
    [_backView setHidden:NO];
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_backView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_backView];
    //加载layer
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    backButton.backgroundColor = [UIColor lightGrayColor];
    backButton.alpha = 0.5;
    [backButton addTarget:self action:@selector(buttonBackClick) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:backButton];
    
    //弹出视图
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 200)];
    view.backgroundColor = [UIColor whiteColor];
    CGRect zeroRect = CGRectZero;
    //头部
        zeroRect.origin.x = 0;
        zeroRect.origin.y =20;
        zeroRect.size.width = self.view.frame.size.width;
        zeroRect.size.height = 30;
        UILabel *label = [[UILabel alloc] initWithFrame:zeroRect];
        label.backgroundColor = [UIColor clearColor];
        [label setText:NSLocalizedString(@"speedSelection", nil)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:RGB(38, 154, 252)];
        [label setBackgroundColor:[UIColor clearColor]];
        [view addSubview:label];
        
        //加热
        UIImage *image = [UIImage imageNamed:@"point3"];
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40, label.frame.size.height+label.frame.origin.y, self.view.frame.size.width - 80, 120)];
        [slider setBackgroundColor:[UIColor clearColor]];
        [slider setMaximumTrackTintColor:[UIColor grayColor]];
        [slider setMinimumTrackTintColor:RGB(0x13, 0xb3, 0x5c)];
        [slider setMaximumValue:3.0f];
        [slider setMinimumValue:1.0f];
        [slider setValue:self.receivedData.gearState];
        image = [UIImage imageNamed:@"seekbar_btn"];
        [slider setThumbImage:image forState:UIControlStateNormal];
        [slider setTag:3];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
        [slider addGestureRecognizer:gr];
        [view addSubview:slider];
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.3f;   //时间间隔
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        animation.type = kCATransitionMoveIn;         //动画效果
        animation.subtype = kCATransitionFromTop;   //动画方向
        [view.layer addAnimation:animation forKey:@"animation"];
        
        //添加说明性文字
        label = [[UILabel alloc] initWithFrame:CGRectMake(40, slider.frame.origin.y + 85, 70, 30)];
        [label setText:[NSString stringWithFormat:@"1%@",NSLocalizedString(@"File", nil)]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:13.f]];
        [view addSubview:label];
        //1档
        label = [[UILabel alloc] initWithFrame:CGRectMake(150, label.frame.origin.y, 70, 30)];
        [label setText:[NSString stringWithFormat:@"2%@",NSLocalizedString(@"File", nil)]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:13.f]];
        [view addSubview:label];
        //2档
        label = [[UILabel alloc] initWithFrame:CGRectMake(270, label.frame.origin.y, 70, 30)];
        [label setText:[NSString stringWithFormat:@"3%@",NSLocalizedString(@"File", nil)]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:13.f]];
        [view addSubview:label];
        [_backView addSubview:view];
}

//阴影点击
-(void)buttonBackClick
{
    //点击阴影的情况
    [_backView removeFromSuperview];
    [_backView setHidden:YES];
}

//定时任务点击
-(void)timerButtonClick
{
    //定时界面
    BLFilterViewController *filterInfoViewController = [[BLFilterViewController alloc] initWithNibName:nil bundle:nil];
	filterInfoViewController.receivedData = self.receivedData;
	filterInfoViewController.device = self.device;
    [self.navigationController pushViewController:filterInfoViewController animated:YES];
}

//风速按钮点击
-(void)speedButtonClick:(UIButton *)button
{
    //如果儿童锁按钮点击，那么提示信息
    if(_childLockButton.selected) {
        //提示信息
		
        [self.view makeToast:NSLocalizedString(@"childMessage", nil) duration:0.8 position:@"bottom"];
        return;
    }
    //如果自动按钮点击，那么提示信息
   else if(_handOrAutoButton.selected) {
        //提示信息
        [self.view makeToast:NSLocalizedString(@"autoMessage", nil) duration:0.8 position:@"bottom"];
        return;
    } else {
          //弹出选择框
        [self popUpView:button];
    }
}

//返回按钮
-(void)leftButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

//进入关于页面
-(void)rightButtonClick:(UIButton *)button
{
    BLAboutViewController *aboutViewControl = [[BLAboutViewController alloc] init];
    [self.navigationController pushViewController:aboutViewControl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //插入定时数据
    BLTimerInfomation *timerInfomation = [BLTimerInfomation timerInfomation];
    if(timerInfomation) {
        //判断定时时间已经过去
        NSDate *datenow = [NSDate date];
        long currentSecond = (long)[datenow timeIntervalSince1970];
        if(currentSecond >= (timerInfomation.secondSince + timerInfomation.secondCount))
            return;
		if(timerInfomation.switchState) {
            [_leftTimerLabel setText:[NSString stringWithFormat:@"%ld%@%ld%@%@",timerInfomation.secondCount / 3600,NSLocalizedString(@"hour", nil),(timerInfomation.secondCount % 3600) / 60,NSLocalizedString(@"minute", nil),NSLocalizedString(@"open", nil)]];
		} else {
            [_leftTimerLabel setText:[NSString stringWithFormat:@"%ld%@%ld%@%@",timerInfomation.secondCount / 3600,NSLocalizedString(@"hour", nil),timerInfomation.secondCount / 60,NSLocalizedString(@"minute", nil),NSLocalizedString(@"close", nil)]];
		}
    }
}

- (void)allButtonClicked:(UIButton *)button
{
    if(!self.receivedData.switchStatus && button != _switchButton) {
        return;
    } else {
        if(_childLockButton.selected) {
            if(button == _handOrAutoButton || button == _sleepButton) {
                [self.view makeToast:NSLocalizedString(@"childMessage", nil) duration:0.8 position:@"bottom"];
                return;
            }
        }
    }
    
    dispatch_async(_networkQueue, ^{
        [MMProgressHUD showWithTitle:@"Network" status:@"Setting"];
        BeiAngSendData *sendData = [[BeiAngSendData alloc] init];
		sendData.switchStatus = self.receivedData.switchStatus;
		sendData.autoOrHand = self.receivedData.autoOrHand;
		sendData.sleepState = self.receivedData.sleepState;
		sendData.childLockState = self.receivedData.childLockState;
		sendData.gearState = self.receivedData.gearState;
        if(button == _switchButton) {
            [sendData setSwitchStatus:!button.selected];
        } else if (button == _handOrAutoButton) {
            [sendData setAutoOrHand:!button.selected];
        } else if (button == _sleepButton) {
            sendData.sleepState = !button.selected;
        } else if(button == _childLockButton) {
            sendData.childLockState = !button.selected;
        }
		
        NSData *response =[self sendDataCommon:sendData];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        if (code == 0) {
            [MMProgressHUD dismiss];
            NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
            self.receivedData = [[BeiAngReceivedData alloc] initWithData:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(button == _handOrAutoButton) {
					[self deviceAutoOn:self.receivedData.autoOrHand];
				} else if (button == _switchButton) {
					[self deviceOn:self.receivedData.switchStatus];
                } else if (button == _sleepButton) {
					[self deviceSleepOn:self.receivedData.sleepState];
                } else if (button == _childLockButton) {
					[self deviceChildLockOn:self.receivedData.childLockState];
                }
			});
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				[MMProgressHUD dismiss];
				[self.view makeToast:[[response objectFromJSONData] objectForKey:@"msg"] duration:0.8f position:@"bottom"];
			});
		}
	});
}

//发送数据
-(NSData *)sendDataCommon:(BeiAngSendData *)sendData
{
	NSDictionary *dictionary = [NSDictionary dictionaryPassthroughWithMAC:self.device.mac switchStatus:@(sendData.switchStatus) autoOrManual:@(sendData.autoOrHand) gearState:@(sendData.gearState) sleepState:@(sendData.sleepState) childLockState:@(sendData.childLockState)];
    NSData *send = [dictionary JSONData];
    NSData *response = [_networkAPI requestDispatch:send];
    return response;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    int index = (int)(slider.value + 0.5); // Round the number.
    [slider setValue:index animated:YES];
    [self setWindSpeed:index];
}

- (void)sliderTapped:(UIGestureRecognizer *)g
{
    UISlider* s = (UISlider *)g.view;
    if (s.highlighted)
        return; // tap on thumb, let slider deal with it
    CGPoint pt = [g locationInView: s];
    CGFloat percentage = pt.x / s.bounds.size.width;
    CGFloat delta = percentage * (s.maximumValue - s.minimumValue);
    CGFloat value = s.minimumValue + delta + 0.5f;
    [s setValue:(int)value animated:YES];
    [self setWindSpeed:(int)value];
}

- (void)setWindSpeed:(int)speed
{
    static int old = 0;
    if (old == speed)
        return;
    old = speed;
    dispatch_async(_networkQueue, ^{
        [MMProgressHUD showWithTitle:@"Network" status:@"Setting"];
        BeiAngSendData *sendData = [[BeiAngSendData alloc] init];
        sendData.childLockState = self.receivedData.childLockState;
        sendData.switchStatus = self.receivedData.switchStatus;
        [sendData setAutoOrHand:self.receivedData.autoOrHand];
        sendData.sleepState = self.receivedData.sleepState;
        sendData.gearState = speed;
        //数据透传
        NSData *response =[self sendDataCommon:sendData];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        if (code == 0) {
            [MMProgressHUD dismiss];
            NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
            self.receivedData = [[BeiAngReceivedData alloc] initWithData:array];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MMProgressHUD dismiss];
                [self.view makeToast:[[response objectFromJSONData] objectForKey:@"msg"] duration:0.8f position:@"bottom"];
            });
        }
    });
}

- (void)share
{
	_shareViewController = [[BLShareViewController alloc] init];
	[_shareViewController share];
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	_currentLocation = locations[0];
	[[[CLGeocoder alloc] init] reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
		if (!error && placemarks.count) {
			CLPlacemark *placemark = placemarks[0];
			_weather.cityName = [[[placemark.addressDictionary objectForKey:@"City"] componentsSeparatedByString:@"市"] objectAtIndex:0];
			_weather.cityCode = [[[NSString citiesCodeString] objectFromJSONString] objectForKey:[[_weather.cityName componentsSeparatedByString:@"市"] objectAtIndex:0]];
			//如果名称不相同则一般为英文
			if(_weather.cityCode.length) {
				[self getWeather];
			} else {
				[self getCityInfo];
			}
		} else {
			NSLog(@"No results were returned.");
		}
	}];
	[manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusDenied) {
		[manager stopUpdatingLocation];
	} else {
		[manager startUpdatingLocation];
	}
}

-(void)getCityInfo
{
    dispatch_async(_httpQueue, ^{
        //百度接口取得地图上面的点
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.map.baidu.com/geocoder?output=json&location=%f,%f&key=37492c0ee6f924cb5e934fa08c6b1676", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude]];
        NSError *error;
        NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        SBJsonParser *parser = [[SBJsonParser alloc]init];
        NSDictionary *rootDic = [parser objectWithString:jsonString error:&error];
        NSDictionary *weatherInfo = [rootDic objectForKey:@"result"];
		_weather.cityName = [[[[weatherInfo objectForKey:@"addressComponent"] objectForKey:@"city"] componentsSeparatedByString:@"市"] objectAtIndex:0];
		_weather.cityCode = [[[NSString citiesCodeString] objectFromJSONString] objectForKey:[[_weather.cityName componentsSeparatedByString:@"市"] objectAtIndex:0]];
		if(_weather.cityCode.length) {
			[self getWeather];
		}
    });
}

//天气接口
- (void)getWeather
{
    dispatch_async(_httpQueue, ^{
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tqapi.mobile.360.cn/app/meizu/city/%@", _weather.cityCode]];
		NSError *error;
		NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
		SBJsonParser *parser = [[SBJsonParser alloc]init];
		NSDictionary *rootDic = [parser objectWithString:jsonString error:&error];
		
		NSMutableString *temperature = [NSMutableString stringWithString:@""];
		NSDictionary *weatherOfToday = rootDic[@"weather"][0];
		NSArray *nightInfomation = weatherOfToday[@"info"][@"night"];
		NSArray *dayInfomation = weatherOfToday[@"info"][@"day"];
		if (nightInfomation.count >= 3 && dayInfomation.count >= 3) {
			[temperature appendString:nightInfomation[2]];
			[temperature appendString:@"~"];
			[temperature appendString:dayInfomation[2]];
			[temperature appendString:@"℃"];
		}
		_weather.temperateStrings = temperature;
		
		NSDictionary *pm25Information = rootDic[@"pm25"];
		if (pm25Information) {
			NSString *pm25 = [NSString stringWithFormat:@"%@", pm25Information[@"pm25"]];
			_weather.pm25 = pm25;
			_weather.airQualityString = pm25Information[@"quality"];
			_weather.airQualityLevel = [NSString stringWithFormat:@"%@", pm25Information[@"level"]];
			_weather.airQualityColorHexString = pm25Information[@"color"];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self refreshWeather];
		});
    });
}
@end
