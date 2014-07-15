//
//  BLAirQualityViewController.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLAirQualityViewController.h"
#import "GlobalDefine.h"
#import "BLAppDelegate.h"
#import "UIImage+Retina4.h"
#import "Toast+UIView.h"
#import "BLFilterViewController.h"
#import "BLDeviceErrorViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "BLAboutViewController.h"
#import "SBJson.h"
#import "MMProgressHUD.h"
#import "UILabel+Attribute.h"
#import "Toast+UIView.h"
#import "UIViewController+MMDrawerController.h"
#import "BLCustomHUD+UIWindow.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "UIImage+Retina4.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BLNetwork.h"

@interface BLAirQualityViewController () <UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
{
    BLAppDelegate *appDelegate;
    BLNetwork *networkAPI;
    dispatch_queue_t networkQueue;
    dispatch_queue_t httpQueue;
    int oldSpeed;
    int oldTimer;
}
//顶部视图
@property (nonatomic, strong) UIView *topView;
//温度
@property (nonatomic, strong) UILabel *weatherLabel;
//点击风速弹出的视图
@property (nonatomic, strong) UIView *backView;
//空气质量指数
@property (nonatomic, strong) UILabel *airQualityLabel;
//开关按钮
@property (nonatomic, strong) UIButton *switchButton;
//手动或者自动按钮
@property (nonatomic, strong) UIButton *handOrAutoButton;
//儿童锁按钮
@property (nonatomic, strong) UIButton *childLockButton;
//手动自动标题
@property (nonatomic, strong) UILabel *handOrAutoLabel;
//睡眠开关标题
@property (nonatomic, strong) UILabel *sleepLabel;
//儿童锁开关标题
@property (nonatomic, strong) UILabel *childLockLabel;
//空气质量标题
@property (nonatomic, strong) UILabel *airQuality;
//城市标题
@property (nonatomic, strong) UILabel *address;
//剩余时间
@property (nonatomic, strong) UILabel *leftTimerLabel;
//定时器
@property (nonatomic, strong) NSTimer *refreshInfoTimer;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, strong) NSTimer *refreshLocationInfo;
@end

@implementation BLAirQualityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (BLAppDelegate *)[[UIApplication sharedApplication] delegate];
    networkAPI = [[BLNetwork alloc] init];
    networkQueue = dispatch_queue_create("BLAirQualityViewCtrollerNetworkQueue", DISPATCH_QUEUE_SERIAL);
    httpQueue = dispatch_queue_create("BLHttpQueue", DISPATCH_QUEUE_SERIAL);
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    
    _locManager = [[CLLocationManager alloc] init];
    [_locManager setDelegate:self];
    [_locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locManager setDistanceFilter:500.0f];
    [_locManager startUpdatingLocation];

    //顶部视图
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = 0;
    viewFrame.origin.y = 0;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height =140.5f;
    _topView = [[UIView alloc] initWithFrame:viewFrame];
    //空气质量
    _topView.backgroundColor = [UIColor themeBlue];
    [self.view addSubview:_topView];
    
    //左侧返回按钮
//    UIImage *image = [UIImage imageNamed:@"left"];
//    viewFrame.origin.x = 0;
//    viewFrame.origin.y = 15;
//    viewFrame.size = image.size;
//    UIButton *leftButton = [[UIButton alloc] initWithFrame:viewFrame];
//    [leftButton setImage:image forState:UIControlStateNormal];
//    [leftButton setBackgroundColor:[UIColor clearColor]];
//    [leftButton addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [self setNaviBarLeftBtn:leftButton];
	
    //右侧关于界面
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_logo"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick:)];
//    UIImage *image = [UIImage imageNamed:@"home_logo"];
//    viewFrame.origin.x = self.view.frame.size.width - image.size.width / 2.f - 10;
//    viewFrame.origin.y = leftButton.frame.origin.y;
//    viewFrame.size.width = image.size.width / 2.f;
//    viewFrame.size.height = leftButton.frame.size.height;
//    UIButton *rightButton = [[UIButton alloc] initWithFrame:viewFrame];
//    [rightButton setImage:image forState:UIControlStateNormal];
//    [rightButton setBackgroundColor:[UIColor clearColor]];
//    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self setNaviBarRightBtn:rightButton];
	
    //城市地址
    viewFrame.origin.x = 20;
    //viewFrame.origin.y = leftButton.frame.size.height + leftButton.frame.origin.y + 5;
	viewFrame.origin.y = 40;//TODO:
    viewFrame.size.width = 20;
    viewFrame.size.height = 20;
    _address = [[UILabel alloc] initWithFrame:viewFrame];
    [_address setBackgroundColor:[UIColor clearColor]];
    [_address setNumberOfLines:1];
    [_address setTextColor:[UIColor whiteColor]];
    [_address setFont:[UIFont systemFontOfSize:17.f]];
    [_address setText:appDelegate.airQualityInfoClass.cityName];
    //根据高度调整长度
    CGSize size = [_address.text sizeWithFont:_address.font constrainedToSize:CGSizeMake(MAXFLOAT, _address.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    viewFrame.size.width = size.width;
    [_address setFrame:viewFrame];
    [_topView addSubview:_address];
    
     //温度
    viewFrame.origin.x = _address.frame.size.width + _address.frame.origin.x + 10;
    viewFrame.origin.y = _address.frame.origin.y;
    viewFrame.size.width = 150;
    viewFrame.size.height = 20;
    _weatherLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [_weatherLabel setBackgroundColor:[UIColor clearColor]];
    [_weatherLabel setNumberOfLines:1];
    [_weatherLabel setTextColor:[UIColor whiteColor]];
    [_weatherLabel setFont:[UIFont systemFontOfSize:25.f]];
    
    @synchronized(appDelegate.airQualityInfoClass)
    {
        [_weatherLabel setText:appDelegate.airQualityInfoClass.temperateStrings];
    }
    [_topView addSubview:_weatherLabel];
    
    //空气质量
    viewFrame.origin.x =  _address.frame.origin.x;
    viewFrame.origin.y = _address.frame.size.height + _address.frame.origin.y + 10.f;
    viewFrame.size.width = 200;
    viewFrame.size.height = 80;
    _airQuality = [[UILabel alloc] initWithFrame:viewFrame];
	_airQuality.numberOfLines = 0;
    [_airQuality setBackgroundColor:[UIColor clearColor]];
    [_airQuality setTextColor:[UIColor whiteColor]];
    @synchronized(appDelegate.airQualityInfoClass) {
		ClassAirQualityInfo *airQuality = appDelegate.airQualityInfoClass;
		_airQuality.text = [NSString stringWithFormat:@"%@ %@\n室外 PM:2.5 %@ %@", airQuality.cityName, airQuality.temperateStrings, airQuality.pm25, airQuality.airQualityString];
    }
    [_airQuality setFont:[UIFont systemFontOfSize:17.f]];
    [_topView addSubview:_airQuality];
    
    //底部视图
    viewFrame.origin.x =  0;
    viewFrame.origin.y = _topView.frame.size.height + _topView.frame.origin.y - 10;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = self.view.frame.size.height - viewFrame.origin.y + 10;
    UIView *bottomView = [[UIView alloc] initWithFrame:viewFrame];
    [bottomView.layer setMasksToBounds:YES];
    [bottomView.layer setCornerRadius:10.f];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    
    //风速
    UIImage *image = [UIImage imageNamed:@"wind"];
    viewFrame.origin.x =  _address.frame.origin.x;
    viewFrame.origin.y = 10;
    viewFrame.size = CGSizeMake(47.f, 47.f);
    UIButton *speedButton = [[UIButton alloc] initWithFrame:viewFrame];
    [speedButton setBackgroundColor:[UIColor clearColor]];
    [speedButton setImage:image forState:UIControlStateNormal];
    [speedButton addTarget:self action:@selector(speedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:speedButton];
    
    //空气质量指数
    UIImage *timeImage = [UIImage imageNamed:@"time"];
    viewFrame.origin.x =  speedButton.frame.origin.x + speedButton.frame.size.width;
    viewFrame.origin.y = 10;
    viewFrame.size.width = self.view.frame.size.width - (47.f + _address.frame.origin.x) * 2;
    viewFrame.size.height = 47.f;
    _airQualityLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [_airQualityLabel setTextAlignment:NSTextAlignmentCenter];
    [_airQualityLabel setBackgroundColor:[UIColor clearColor]];
	_airQualityLabel.numberOfLines = 0;
    @synchronized(appDelegate.airQualityInfoClass) {
		NSLog(@"airQualityInfoClass: %@", appDelegate.airQualityInfoClass);
        [_airQualityLabel setText:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"airQiality", nil),appDelegate.airQualityInfoClass.airQualityLevel]];
    }
    [_airQualityLabel setTextColor:[UIColor blackColor]];
    [_airQualityLabel setFont:[UIFont systemFontOfSize:15.f]];
    [bottomView addSubview:_airQualityLabel];
    
    //定时任务
    viewFrame.origin.x =  self.view.frame.size.width - speedButton.frame.size.width - _address.frame.origin.x;
    viewFrame.origin.y = speedButton.frame.origin.y;
    viewFrame.size = speedButton.frame.size;
    UIButton *timerButton = [[UIButton alloc] initWithFrame:viewFrame];
    [timerButton setBackgroundColor:[UIColor clearColor]];
    [timerButton setImage:timeImage forState:UIControlStateNormal];
    [timerButton addTarget:self action:@selector(timerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:timerButton];
    
    //开关按钮
    _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_switchButton.selected = self.currentAirInfo.switchStatus ? YES : NO;
	NSString *pathOnOff = self.currentAirInfo.switchStatus ? @"power_on" : @"power_off";
	NSString *pathOnOffClick = self.currentAirInfo.switchStatus ? @"power_on_press" : @"power_off_press";
    UIImage *imageSwitchState = [UIImage imageNamed:pathOnOff];
    UIImage *imageSwitchClick = [UIImage imageNamed:pathOnOffClick];
    viewFrame.origin.x =  (self.view.frame.size.width - imageSwitchState.size.width) / 2.f;
    viewFrame.origin.y = timerButton.frame.origin.y + timerButton.frame.size.height + 15.f;
    viewFrame.size = imageSwitchState.size;
    [_switchButton setFrame:viewFrame];
    [_switchButton setImage:imageSwitchState forState:UIControlStateNormal];
    [_switchButton setImage:imageSwitchClick forState:UIControlStateSelected | UIControlStateHighlighted];
    [_switchButton setTag:1];
    [_switchButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_switchButton];
    
    //手动按钮
    _handOrAutoButton  = [UIButton buttonWithType:UIButtonTypeCustom];
	_handOrAutoButton.selected = self.currentAirInfo.autoOrHand ? YES : NO;
	pathOnOff = self.currentAirInfo.autoOrHand ? @"auto_on" : @"hand_on";
	pathOnOffClick = self.currentAirInfo.autoOrHand ? @"auto_on_press" : @"hand_on_press";
    imageSwitchState = [UIImage imageNamed:pathOnOff];
    imageSwitchClick = [UIImage imageNamed:pathOnOffClick];
    viewFrame.origin.x =  _address.frame.origin.x;
    viewFrame.origin.y = _switchButton.frame.origin.y + _switchButton.frame.size.height;
    viewFrame.size = imageSwitchState.size;
    [_handOrAutoButton setFrame:viewFrame];
    [_handOrAutoButton setImage:imageSwitchState forState:UIControlStateNormal];
    [_handOrAutoButton setImage:imageSwitchClick forState:UIControlStateHighlighted | UIControlStateSelected];
    [_handOrAutoButton setTag:2];
    [_handOrAutoButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_handOrAutoButton];
    
    //手动自动标题
    viewFrame.origin.y = _handOrAutoButton.frame.size.height + _handOrAutoButton.frame.origin.y;
    _handOrAutoLabel = [[UILabel alloc] initWithFrame:viewFrame];
	[_handOrAutoLabel setFont:[UIFont systemFontOfSize:13.f]];
	[_handOrAutoLabel setNumberOfLines:2];
	_handOrAutoLabel.text = self.currentAirInfo.autoOrHand ? NSLocalizedString(@"Automatic", nil) : NSLocalizedString(@"Manual", nil);
	
    //根据长度调帐高度
    size = [_handOrAutoLabel.text sizeWithFont:_handOrAutoLabel.font constrainedToSize:CGSizeMake(viewFrame.size.width, MAXFLOAT)  lineBreakMode:NSLineBreakByWordWrapping];
    viewFrame.size.height = size.height;
    [_handOrAutoLabel setFrame:viewFrame];
    [_handOrAutoLabel setBackgroundColor:[UIColor clearColor]];
    [_handOrAutoLabel setTextColor:[UIColor blackColor]];
    [_handOrAutoLabel setTextAlignment:NSTextAlignmentCenter];
    [bottomView addSubview:_handOrAutoLabel];
    
    //睡眠按钮
    UIButton *sleepButton  = [UIButton buttonWithType:UIButtonTypeCustom];
	sleepButton.selected = self.currentAirInfo.sleepState ? YES : NO;
	pathOnOff = self.currentAirInfo.sleepState ? @"night_on" : @"night_off";
	pathOnOffClick = self.currentAirInfo.sleepState ? @"night_on_press" : @"night_off_press";
    imageSwitchState = [UIImage imageNamed:pathOnOff];
    imageSwitchClick = [UIImage imageNamed:pathOnOffClick];
    viewFrame.origin.x =  (self.view.frame.size.width - imageSwitchState.size.width) / 2.f;
    viewFrame.origin.y = _handOrAutoButton.frame.origin.y + _handOrAutoButton.frame.size.height * 2.f / 3.f;
    viewFrame.size = imageSwitchState.size;
    [sleepButton setFrame:viewFrame];
    [sleepButton setImage:imageSwitchState forState:UIControlStateNormal];
    [sleepButton setImage:imageSwitchClick forState:UIControlStateHighlighted | UIControlStateSelected];
    [sleepButton setTag:3];
    [sleepButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sleepButton];
    
    //睡眠标题
    viewFrame.origin.y = sleepButton.frame.size.height + sleepButton.frame.origin.y;
    _sleepLabel = [[UILabel alloc] initWithFrame:viewFrame];
	_sleepLabel.text = self.currentAirInfo.sleepState ? NSLocalizedString(@"SleepOn", nil) : NSLocalizedString(@"SleepOff", nil);
    [_sleepLabel setBackgroundColor:[UIColor clearColor]];
    [_sleepLabel setFont:[UIFont systemFontOfSize:13.f]];
    [_sleepLabel setNumberOfLines:2];
    //根据长度调帐高度
    size = [_sleepLabel.text sizeWithFont:_sleepLabel.font constrainedToSize:CGSizeMake(viewFrame.size.width, MAXFLOAT)  lineBreakMode:NSLineBreakByWordWrapping];
    viewFrame.size.height = size.height;
    [_sleepLabel setFrame:viewFrame];
    [_sleepLabel setTextColor:[UIColor blackColor]];
    [_sleepLabel setTextAlignment:NSTextAlignmentCenter];
    [bottomView addSubview:_sleepLabel];
    
    //儿童锁按钮
    _childLockButton  = [UIButton buttonWithType:UIButtonTypeCustom];
	_childLockButton.selected = self.currentAirInfo.childLockState ? YES : NO;
	pathOnOff = self.currentAirInfo.childLockState ? @"lock_on" : @"lock_off";
	pathOnOffClick = self.currentAirInfo.childLockState ? @"lock_on_press" : @"lock_off_press";
    imageSwitchState = [UIImage imageNamed:pathOnOff];
    imageSwitchClick = [UIImage imageNamed:pathOnOffClick];
    viewFrame.origin.x =  self.view.frame.size.width - imageSwitchState.size.width - _address.frame.origin.x;
    viewFrame.origin.y = _handOrAutoButton.frame.origin.y ;
    viewFrame.size = imageSwitchState.size;
    [_childLockButton setFrame:viewFrame];
    [_childLockButton setImage:imageSwitchState forState:UIControlStateNormal];
    [_childLockButton setImage:imageSwitchClick forState:UIControlStateHighlighted | UIControlStateSelected];
    [_childLockButton setTag:4];
    [_childLockButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_childLockButton];
    
    //儿童锁标题
    viewFrame.origin.y = _childLockButton.frame.size.height + _childLockButton.frame.origin.y;
    _childLockLabel = [[UILabel alloc] initWithFrame:viewFrame];
	_childLockLabel.text = self.currentAirInfo.childLockState ? NSLocalizedString(@"TheChildLock", nil) : NSLocalizedString(@"TheChildLockOff", nil);
    [_childLockLabel setBackgroundColor:[UIColor clearColor]];
    [_childLockLabel setFont:[UIFont systemFontOfSize:13.f]];
    [_childLockLabel setNumberOfLines:3];
    //根据长度调帐高度
    size = [_childLockLabel.text sizeWithFont:[UIFont systemFontOfSize:13.f] constrainedToSize:CGSizeMake(viewFrame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    viewFrame.size.height = size.height;
    [_childLockLabel setFrame:viewFrame];
    [_childLockLabel setTextColor:[UIColor blackColor]];
    [_childLockLabel setTextAlignment:NSTextAlignmentCenter];
    [bottomView addSubview:_childLockLabel];
    
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
	
  //TODO:
//    [self.view bringSubviewToFront:rightButton];
//    [self.view bringSubviewToFront:leftButton];
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
        [slider setValue:self.currentAirInfo.gearState];
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
    BLFilterViewController *filterInfoViewController = [[BLFilterViewController alloc] init];
	filterInfoViewController.currentAirInfo = self.currentAirInfo;
	filterInfoViewController.deviceInfo = self.deviceInfo;
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
    NSLog(@"timerInfomation = %@",timerInfomation);
    if(timerInfomation)
    {
        //判断定时时间已经过去
        NSDate *datenow = [NSDate date];
        long currentSecond = (long)[datenow timeIntervalSince1970];
        if(currentSecond >= (timerInfomation.secondSince + timerInfomation.secondCount))
            return;
        
        if(timerInfomation.switchState)
            [_leftTimerLabel setText:[NSString stringWithFormat:@"%ld%@%ld%@%@",timerInfomation.secondCount / 3600,NSLocalizedString(@"hour", nil),(timerInfomation.secondCount % 3600) / 60,NSLocalizedString(@"minute", nil),NSLocalizedString(@"open", nil)]];
        else
            [_leftTimerLabel setText:[NSString stringWithFormat:@"%ld%@%ld%@%@",timerInfomation.secondCount / 3600,NSLocalizedString(@"hour", nil),timerInfomation.secondCount / 60,NSLocalizedString(@"minute", nil),NSLocalizedString(@"close", nil)]];
    }
    
    //定时
    _refreshInfoTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getInfo:) userInfo:nil repeats:YES];
    [_refreshInfoTimer fire];
}

//刷新
-(void)getInfo:(NSTimer *)timer
{
    @synchronized(appDelegate.airQualityInfoClass)
    {
        //温度
        NSLog(@"%@", appDelegate.airQualityInfoClass.temperateStrings);
        if(appDelegate.airQualityInfoClass.temperateStrings.length > 0)
        {
            _address.text = appDelegate.airQualityInfoClass.cityName;
            _airQuality.text = appDelegate.airQualityInfoClass.airQualityString;
            _weatherLabel.text = appDelegate.airQualityInfoClass.temperateStrings;
            [_airQualityLabel setText:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"airQiality", nil),appDelegate.airQualityInfoClass.airQualityLevel]];
            //判断空气质量级别
            if([appDelegate.airQualityInfoClass.airQualityLevel isEqualToString:@"4"])
            {
                UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"weather_layout_color_bg.png"]];
                _topView.backgroundColor = color;
            }
            [timer invalidate];
            timer = nil;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dispatch_release(networkQueue);
    dispatch_release(httpQueue);
}

//自动或者手动按钮点击
- (void)allButtonClicked:(UIButton *)button
{
    //判断是否开机状态
    if(!self.currentAirInfo.switchStatus && button.tag != 1)
    {
        //关机状态就返回
        return;
    }
    else
    {
        //判断儿童锁是否开启
        if(_childLockButton.selected)
        {
            if(button.tag == 2 || button.tag == 3)
            {
                //提示信息
                [self.view makeToast:NSLocalizedString(@"childMessage", nil) duration:0.8 position:@"bottom"];
                return;
            }
        }
    }
    
    dispatch_async(networkQueue, ^{
        [MMProgressHUD showWithTitle:@"Network" status:@"Setting"];
        BeiAngSendDataInfo *sendInfo = [[BeiAngSendDataInfo alloc] init];
        //判断是那个按钮点击
        if(button.tag == 1)
        {
            //开关按钮
            [sendInfo setSwitchStatus:!button.selected];
            [sendInfo setAutoOrHand:self.currentAirInfo.autoOrHand];
            sendInfo.sleepState = self.currentAirInfo.sleepState;
            sendInfo.childLockState = self.currentAirInfo.childLockState;
        }
        else if (button.tag == 2)
        {
            //自动或者手动按钮
            [sendInfo setAutoOrHand:!button.selected];
            sendInfo.switchStatus = self.currentAirInfo.switchStatus;
            sendInfo.sleepState = self.currentAirInfo.sleepState;
            sendInfo.childLockState = self.currentAirInfo.childLockState;
        }
        else if (button.tag == 3)
        {
            //睡眠按钮
            sendInfo.sleepState = !button.selected;
            sendInfo.switchStatus = self.currentAirInfo.switchStatus;
            [sendInfo setAutoOrHand:self.currentAirInfo.autoOrHand];
            sendInfo.childLockState = self.currentAirInfo.childLockState;
        }
        else if(button.tag == 4)
        {
            //儿童锁按钮
            sendInfo.childLockState = !button.selected;
            sendInfo.switchStatus = self.currentAirInfo.switchStatus;
            [sendInfo setAutoOrHand:self.currentAirInfo.autoOrHand];
            sendInfo.sleepState = self.currentAirInfo.sleepState;
        }
        sendInfo.gearState = self.currentAirInfo.gearState;
        
        //数据透传
        NSData *response =[self sendDataCommon:sendInfo];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        if (code == 0)
        {
            [MMProgressHUD dismiss];
            NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
            BeiAngReceivedDataInfo *recvInfo = [[BeiAngReceivedDataInfo alloc] init];
            //数据转换
            recvInfo = [self turnArrayToBeiAngReceivedDataInfo:array];
            self.currentAirInfo = recvInfo;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *stringSwitchState;
                NSString *stringSwitchClick;
                //判断是那个按钮点击
                if(button.tag == 2)
                {
                    //手动或者自动按钮
                    if(self.currentAirInfo.autoOrHand)
                    {
                        stringSwitchState = @"auto_on";
                        stringSwitchClick = @"auto_on_press";
                        [_handOrAutoLabel setText:NSLocalizedString(@"Automatic", nil)];
                        button.selected = YES;
                    }
                    else
                    {
                        stringSwitchState = @"hand_on";
                        stringSwitchClick = @"hand_on_press";
                        [_handOrAutoLabel setText:NSLocalizedString(@"Manual", nil)];
                        button.selected = NO;
                    }
                }
                else if (button.tag == 1)
                {
                    //判断开关按钮
                    if(self.currentAirInfo.switchStatus)
                    {
                        stringSwitchState = @"power_on";
                        stringSwitchClick = @"power_on_press";
                        button.selected = YES;
                    }
                    else
                    {
                        stringSwitchState = @"power_off";
                        stringSwitchClick = @"power_off_press";
                        button.selected = NO;
                    }
                }
                else if (button.tag == 3)
                {
                    //判断睡眠按钮
                    if(self.currentAirInfo.sleepState)
                    {
                        stringSwitchState = @"night_on";
                        stringSwitchClick = @"night_on_press";
                        [_sleepLabel setText:NSLocalizedString(@"SleepOn", nil)];
                        button.selected = YES;
                    }
                    else
                    {
                        stringSwitchState = @"night_off";
                        stringSwitchClick = @"night_off_press";
                        [_sleepLabel setText:NSLocalizedString(@"SleepOff", nil)];
                        button.selected = NO;
                    }
                }
                else if (button.tag == 4)
                {
                    //判断儿童锁按钮
                    if(self.currentAirInfo.childLockState)
                    {
                        stringSwitchState = @"lock_on";
                        stringSwitchClick = @"lock_on_press";
                        [_childLockLabel setText:NSLocalizedString(@"TheChildLock", nil)];
                        button.selected = YES;
                    }
                    else
                    {
                        stringSwitchState = @"lock_off";
                        stringSwitchClick = @"lock_off_press";
                        [_childLockLabel setText:NSLocalizedString(@"TheChildLockOff", nil)];
                        button.selected = NO;
                    }
                }
                UIImage *imageSwitchState = [UIImage imageNamed:stringSwitchState];
                UIImage *imageSwitchClick = [UIImage imageNamed:stringSwitchClick];
                [button setImage:imageSwitchState forState:UIControlStateNormal];
                [button setImage:imageSwitchClick forState:UIControlStateHighlighted];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MMProgressHUD dismiss];
                    [self.view makeToast:[[response objectFromJSONData] objectForKey:@"msg"] duration:0.8f position:@"bottom"];
                });
            }
        });
}

//发送数据
-(NSData *)sendDataCommon:(BeiAngSendDataInfo *)sendInfo
{
	NSDictionary *dictionary = [NSDictionary dictionaryPassthroughWithMAC:self.deviceInfo.mac switchStatus:@(sendInfo.switchStatus) autoOrManual:@(sendInfo.autoOrHand) gearState:@(sendInfo.gearState) sleepState:@(sendInfo.sleepState) childLockState:@(sendInfo.childLockState)];
    NSData *sendData = [dictionary JSONData];
    NSData *response = [networkAPI requestDispatch:sendData];
    return response;
}

//根据传入的数组取得接受数据
-(BeiAngReceivedDataInfo *)turnArrayToBeiAngReceivedDataInfo:(NSArray *)array
{
    BeiAngReceivedDataInfo *recvInfo = [[BeiAngReceivedDataInfo alloc] initWithData:array];
    return recvInfo;
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
    dispatch_async(networkQueue, ^{
        [MMProgressHUD showWithTitle:@"Network" status:@"Setting"];
        BeiAngSendDataInfo *sendInfo = [[BeiAngSendDataInfo alloc] init];
        sendInfo.childLockState = self.currentAirInfo.childLockState;
        sendInfo.switchStatus = self.currentAirInfo.switchStatus;
        [sendInfo setAutoOrHand:self.currentAirInfo.autoOrHand];
        sendInfo.sleepState = self.currentAirInfo.sleepState;
        sendInfo.gearState = speed;
        //数据透传
        NSData *response =[self sendDataCommon:sendInfo];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        if (code == 0)
        {
            [MMProgressHUD dismiss];
            NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
            BeiAngReceivedDataInfo *recvInfo = [[BeiAngReceivedDataInfo alloc] init];
            //数据转换
            recvInfo = [self turnArrayToBeiAngReceivedDataInfo:array];
            self.currentAirInfo = recvInfo;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MMProgressHUD dismiss];
                [self.view makeToast:[[response objectFromJSONData] objectForKey:@"msg"] duration:0.8f position:@"bottom"];
            });
        }
    });
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //有数据的场合停止检索
    NSLog(@"_weatherLabel = %d", _weatherLabel.text.length);
    if(_weatherLabel.text.length > 0) {
        [manager stopUpdatingLocation];
        return;
    }
    _geocoder = [[CLGeocoder alloc] init];
    [_geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            _latitude = newLocation.coordinate.latitude;
            _longitude = newLocation.coordinate.longitude;
            NSLog(@"_latitude = %f",_latitude);
            NSLog(@"_longitude = %f",_longitude);
            @synchronized(appDelegate.airQualityInfoClass) {
                //城市名称
                appDelegate.airQualityInfoClass.cityName = [[[placemark.addressDictionary objectForKey:@"City"] componentsSeparatedByString:@"市"] objectAtIndex:0];
                _address.text = appDelegate.airQualityInfoClass.cityName;
                //城市code
				
                appDelegate.airQualityInfoClass.cityCode = [[[NSString citiesCodeString] objectFromJSONString] objectForKey:[[appDelegate.airQualityInfoClass.cityName componentsSeparatedByString:@"市"] objectAtIndex:0]];
                NSLog(@"cityCode = %d",appDelegate.airQualityInfoClass.cityCode.length);
                //如果名称不相同则一般为英文
                //取得空气质量
                if(appDelegate.airQualityInfoClass.cityCode.length > 0) {
					//[self getWeather];//TODO:
                }
                else {
					//[self getCityInfo];//TODO:
                }
            }
        }
        else if (error == nil && [placemarks count] == 0) {
            NSLog(@"No results were returned.");
        } else if (error != nil) {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    [manager stopUpdatingLocation];
}

-(void)getCityInfo
{
    dispatch_async(httpQueue, ^{
        //百度接口取得地图上面的点
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.map.baidu.com/geocoder?output=json&location=%f,%f&key=37492c0ee6f924cb5e934fa08c6b1676",_latitude,_longitude]];
        NSError *error=nil;
        NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        SBJsonParser *parser = [[SBJsonParser alloc]init];
        NSDictionary *rootDic = [parser objectWithString:jsonString error:&error];
        NSDictionary *weatherInfo = [rootDic objectForKey:@"result"];
        @synchronized(appDelegate.airQualityInfoClass) {
            appDelegate.airQualityInfoClass.cityName = [[[[weatherInfo objectForKey:@"addressComponent"] objectForKey:@"city"] componentsSeparatedByString:@"市"] objectAtIndex:0];
            _address.text = appDelegate.airQualityInfoClass.cityName;
            //城市code
            appDelegate.airQualityInfoClass.cityCode = [[[NSString citiesCodeString] objectFromJSONString] objectForKey:[[appDelegate.airQualityInfoClass.cityName componentsSeparatedByString:@"市"] objectAtIndex:0]];
            if(appDelegate.airQualityInfoClass.cityCode.length > 0) {
				[self getWeather];
            }
        }
    });
}

//天气接口
- (void)getWeather
{
    dispatch_async(httpQueue, ^{
        @synchronized(appDelegate.airQualityInfoClass)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tqapi.mobile.360.cn/app/meizu/city/%@", appDelegate.airQualityInfoClass.cityCode]];
            NSError *error=nil;
            NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
            SBJsonParser *parser = [[SBJsonParser alloc]init];
            NSDictionary *rootDic = [parser objectWithString:jsonString error:&error];
            NSDictionary *weatherInfo = [rootDic objectForKey:@"pm25"];
            //空气质量
            NSString *tmp =  [NSString stringWithFormat:@"%@",[weatherInfo objectForKey:@"quality"]];
            if(tmp.length > 0 && ![tmp isEqual:@"(null)"])
                _airQuality.text = appDelegate.airQualityInfoClass.airQualityString;
            //温度
            NSMutableArray *dayArray = [[NSMutableArray alloc] init];
            NSMutableArray *nightArray = [[NSMutableArray alloc] init];
            //温度最低
            dayArray = [[[rootDic objectForKey:@"weather"][0] objectForKey:@"info"] objectForKey:@"night"];
            //温度最高
            nightArray = [[[rootDic objectForKey:@"weather"][0] objectForKey:@"info"] objectForKey:@"day"];
            //空气质量等级
            if([NSString stringWithFormat:@"%@",[weatherInfo objectForKey:@"level"]].length > 0)
            {
                [_airQualityLabel setText:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"airQiality", nil),appDelegate.airQualityInfoClass.airQualityLevel]];
                //判断空气质量级别
                if([appDelegate.airQualityInfoClass.airQualityLevel isEqualToString:@"4"])
                {
                    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"weather_layout_color_bg.png"]];
                    _topView.backgroundColor = color;
                }
            }
            //天气
            appDelegate.airQualityInfoClass.weather = dayArray[1];
            //温度
            NSString *tmpDay =  dayArray[2];
            NSString *tmpNight =  nightArray[2];
            if(tmpDay.length > 0 && tmpNight.length > 0 && ![tmpDay isEqual:@"(null)"] && ![tmpNight isEqual:@"(null)"])
               _weatherLabel.text  = [NSString stringWithFormat:@"%@℃~%@℃",tmpDay,tmpNight] ;
        }
    });
}
@end
