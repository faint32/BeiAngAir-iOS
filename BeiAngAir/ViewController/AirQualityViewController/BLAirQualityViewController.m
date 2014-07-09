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
#import "Toast+UIView.h"
#import "BLFilterViewController.h"
#import "BLDeviceErrorViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "BLAboutViewController.h"
#import "SBJson.h"
#import "MMProgressHUD.h"
#import "CustomNaviBarView.h"
#import "CustomNavigationController.h"
#import "BLFMDBSqlite.h"
#import "Toast+UIView.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
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
    BLFMDBSqlite *sqlite;
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

- (void)dealloc
{
    [super dealloc];
    //顶部视图
    [self setTopView:nil];
    //温度
    [self setWeatherLabel:nil];
    //点击风速弹出的视图
    [self setBackView:nil];
    //空气质量指数
    [self setAirQualityLabel:nil];
    //开关按钮
    [self setSwitchButton:nil];
    //手动或者自动按钮
    [self setHandOrAutoButton:nil];
    //手动自动标题
    [self setHandOrAutoLabel:nil];
    //睡眠开关标题
    [self setSleepLabel:nil];
    //儿童锁开关标题
    [self setChildLockLabel:nil];
    [self setAddress:nil];
    [self setLeftTimerLabel:nil];
    [self setLocManager:nil];
    [self setGeocoder:nil];
    [_refreshInfoTimer invalidate];
    _refreshInfoTimer = nil;
    [_refreshLocationInfo invalidate];
    _refreshLocationInfo = nil;
    dispatch_release(networkQueue);
    dispatch_release(httpQueue);
}

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
    networkAPI = [[BLNetwork alloc] init];
    networkQueue = dispatch_queue_create("BLAirQualityViewCtrollerNetworkQueue", DISPATCH_QUEUE_SERIAL);
    httpQueue = dispatch_queue_create("BLHttpQueue", DISPATCH_QUEUE_SERIAL);
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    sqlite = [BLFMDBSqlite sharedFMDBSqlite];
    
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
    _topView.backgroundColor = RGB(1, 178, 249);
    [self.view addSubview:_topView];
    
    //左侧返回按钮
    NSString *path = [[NSBundle mainBundle] pathForResource:@"left@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    viewFrame.origin.x = 0;
    viewFrame.origin.y = 15;
    viewFrame.size = image.size;
    UIButton *leftButton = [[UIButton alloc] initWithFrame:viewFrame];
    [leftButton setImage:image forState:UIControlStateNormal];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [leftButton addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self setNaviBarLeftBtn:leftButton];
    
    //右侧关于界面
    path = [[NSBundle mainBundle] pathForResource:@"home_logo@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame.origin.x = self.view.frame.size.width - image.size.width / 2.f - 10;
    viewFrame.origin.y = leftButton.frame.origin.y;
    viewFrame.size.width = image.size.width / 2.f;
    viewFrame.size.height = leftButton.frame.size.height;
    UIButton *rightButton = [[UIButton alloc] initWithFrame:viewFrame];
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self setNaviBarRightBtn:rightButton];
    
    //城市地址
    viewFrame.origin.x = 20;
    viewFrame.origin.y = leftButton.frame.size.height + leftButton.frame.origin.y + 5;
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
    viewFrame.size.height = _address.frame.size.height;
    _airQuality = [[UILabel alloc] initWithFrame:viewFrame];
    [_airQuality setBackgroundColor:[UIColor clearColor]];
    [_airQuality setNumberOfLines:1];
    [_airQuality setTextColor:[UIColor whiteColor]];
    @synchronized(appDelegate.airQualityInfoClass)
    {
        [_airQuality setText:appDelegate.airQualityInfoClass.airQualityString];
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
    path = [[NSBundle mainBundle] pathForResource:@"wind@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame.origin.x =  _address.frame.origin.x;
    viewFrame.origin.y = 10;
    viewFrame.size = CGSizeMake(47.f, 47.f);
    UIButton *speedButton = [[UIButton alloc] initWithFrame:viewFrame];
    [speedButton setBackgroundColor:[UIColor clearColor]];
    [speedButton setImage:image forState:UIControlStateNormal];
    [speedButton addTarget:self action:@selector(speedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:speedButton];
    
    //空气质量指数
    path = [[NSBundle mainBundle] pathForResource:@"time@2x" ofType:@"png"];
    UIImage *timeImage = [UIImage imageWithContentsOfFile:path];
    viewFrame.origin.x =  speedButton.frame.origin.x + speedButton.frame.size.width;
    viewFrame.origin.y = 10;
    viewFrame.size.width = self.view.frame.size.width - (47.f + _address.frame.origin.x) * 2;
    viewFrame.size.height = 47.f;
    _airQualityLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [_airQualityLabel setTextAlignment:NSTextAlignmentCenter];
    [_airQualityLabel setBackgroundColor:[UIColor clearColor]];
    @synchronized(appDelegate.airQualityInfoClass)
    {
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
    NSString *pathOnOff;
    NSString *pathOnOffClick;
    //判断开关按钮
    NSLog(@"switchStatus = %d",appDelegate.currentAirInfo.switchStatus);
    if(appDelegate.currentAirInfo.switchStatus)
    {
        pathOnOff = [[NSBundle mainBundle] pathForResource:@"power_on@2x" ofType:@"png"];
        pathOnOffClick = [[NSBundle mainBundle] pathForResource:@"power_on_press@2x" ofType:@"png"];
        _switchButton.selected = YES;
    }
    else
    {
        pathOnOff = [[NSBundle mainBundle] pathForResource:@"power_off@2x" ofType:@"png"];
        pathOnOffClick = [[NSBundle mainBundle] pathForResource:@"power_off_press@2x" ofType:@"png"];
        _switchButton.selected = NO;
    }
    UIImage *imageSwitchState = [UIImage imageWithContentsOfFile:pathOnOff];
    UIImage *imageSwitchClick = [UIImage imageWithContentsOfFile:pathOnOffClick];
    viewFrame.origin.x =  (self.view.frame.size.width - imageSwitchState.size.width) / 2.f;
    viewFrame.origin.y = timerButton.frame.origin.y + timerButton.frame.size.height + 15.f;
    viewFrame.size = imageSwitchState.size;
    [_switchButton setFrame:viewFrame];
    [_switchButton setImage:imageSwitchState forState:UIControlStateNormal];
    [_switchButton setImage:imageSwitchClick forState:UIControlStateHighlighted];
    [_switchButton setTag:1];
    [_switchButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_switchButton];
    
    //手动按钮
    _handOrAutoButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    //判断手动还是自动按钮
    if(appDelegate.currentAirInfo.autoOrHand)
    {
        pathOnOff = [[NSBundle mainBundle] pathForResource:@"auto_on@2x" ofType:@"png"];
        pathOnOffClick = [[NSBundle mainBundle] pathForResource:@"auto_on_press@2x" ofType:@"png"];
        _handOrAutoButton.selected = YES;
    }
    else
    {
        pathOnOff = [[NSBundle mainBundle] pathForResource:@"hand_on@2x" ofType:@"png"];
        pathOnOffClick = [[NSBundle mainBundle] pathForResource:@"hand_on_press@2x" ofType:@"png"];
        _handOrAutoButton.selected = NO;
    }
    imageSwitchState = [UIImage imageWithContentsOfFile:pathOnOff];
    imageSwitchClick = [UIImage imageWithContentsOfFile:pathOnOffClick];
    viewFrame.origin.x =  _address.frame.origin.x;
    viewFrame.origin.y = _switchButton.frame.origin.y + _switchButton.frame.size.height;
    viewFrame.size = imageSwitchState.size;
    [_handOrAutoButton setFrame:viewFrame];
    [_handOrAutoButton setImage:imageSwitchState forState:UIControlStateNormal];
    [_handOrAutoButton setImage:imageSwitchClick forState:UIControlStateHighlighted];
    [_handOrAutoButton setTag:2];
    [_handOrAutoButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_handOrAutoButton];
    
    //手动自动标题
    viewFrame.origin.y = _handOrAutoButton.frame.size.height + _handOrAutoButton.frame.origin.y;
    _handOrAutoLabel = [[UILabel alloc] initWithFrame:viewFrame];
    if(appDelegate.currentAirInfo.autoOrHand)
    {
        [_handOrAutoLabel setText:NSLocalizedString(@"Automatic", nil)];
    }
    else
    {
        [_handOrAutoLabel setText:NSLocalizedString(@"Manual", nil)];
    }
    [_handOrAutoLabel setFont:[UIFont systemFontOfSize:13.f]];
    [_handOrAutoLabel setNumberOfLines:2];
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
    //判断睡眠按钮
    if(appDelegate.currentAirInfo.sleepState)
    {
        pathOnOff = [[NSBundle mainBundle] pathForResource:@"night_on@2x" ofType:@"png"];
        pathOnOffClick = [[NSBundle mainBundle] pathForResource:@"night_on_press@2x" ofType:@"png"];
        sleepButton.selected = YES;
    }
    else
    {
        pathOnOff = [[NSBundle mainBundle] pathForResource:@"night_off@2x" ofType:@"png"];
        pathOnOffClick = [[NSBundle mainBundle] pathForResource:@"night_off_press@2x" ofType:@"png"];
        sleepButton.selected = NO;
    }
    imageSwitchState = [UIImage imageWithContentsOfFile:pathOnOff];
    imageSwitchClick = [UIImage imageWithContentsOfFile:pathOnOffClick];
    viewFrame.origin.x =  (self.view.frame.size.width - imageSwitchState.size.width) / 2.f;
    viewFrame.origin.y = _handOrAutoButton.frame.origin.y + _handOrAutoButton.frame.size.height * 2.f / 3.f;
    viewFrame.size = imageSwitchState.size;
    [sleepButton setFrame:viewFrame];
    [sleepButton setImage:imageSwitchState forState:UIControlStateNormal];
    [sleepButton setImage:imageSwitchClick forState:UIControlStateHighlighted];
    [sleepButton setTag:3];
    [sleepButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:sleepButton];
    
    //睡眠标题
    viewFrame.origin.y = sleepButton.frame.size.height + sleepButton.frame.origin.y;
    _sleepLabel = [[UILabel alloc] initWithFrame:viewFrame];
    if(appDelegate.currentAirInfo.sleepState)
    {
        [_sleepLabel setText:NSLocalizedString(@"SleepOn", nil)];
    }
    else
    {
        [_sleepLabel setText:NSLocalizedString(@"SleepOff", nil)];
    }
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
    //判断儿童锁按钮
    if(appDelegate.currentAirInfo.childLockState)
    {
        pathOnOff = [[NSBundle mainBundle] pathForResource:@"lock_on@2x" ofType:@"png"];
        pathOnOffClick = [[NSBundle mainBundle] pathForResource:@"lock_on_press@2x" ofType:@"png"];
        _childLockButton.selected = YES;
    }
    else
    {
        pathOnOff = [[NSBundle mainBundle] pathForResource:@"lock_off@2x" ofType:@"png"];
        pathOnOffClick = [[NSBundle mainBundle] pathForResource:@"lock_off_press@2x" ofType:@"png"];
        _childLockButton.selected = NO;
    }
    imageSwitchState = [UIImage imageWithContentsOfFile:pathOnOff];
    imageSwitchClick = [UIImage imageWithContentsOfFile:pathOnOffClick];
    viewFrame.origin.x =  self.view.frame.size.width - imageSwitchState.size.width - _address.frame.origin.x;
    viewFrame.origin.y = _handOrAutoButton.frame.origin.y ;
    viewFrame.size = imageSwitchState.size;
    [_childLockButton setFrame:viewFrame];
    [_childLockButton setImage:imageSwitchState forState:UIControlStateNormal];
    [_childLockButton setImage:imageSwitchClick forState:UIControlStateHighlighted];
    [_childLockButton setTag:4];
    [_childLockButton addTarget:self action:@selector(allButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_childLockButton];
    
    //儿童锁标题
    viewFrame.origin.y = _childLockButton.frame.size.height + _childLockButton.frame.origin.y;
    _childLockLabel = [[UILabel alloc] initWithFrame:viewFrame];
    if(appDelegate.currentAirInfo.childLockState)
    {
        [_childLockLabel setText:NSLocalizedString(@"TheChildLock", nil)];
    }
    else
    {
        [_childLockLabel setText:NSLocalizedString(@"TheChildLockOff", nil)];
    }
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
    
    [self.view bringSubviewToFront:rightButton];
    [self.view bringSubviewToFront:leftButton];
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
        NSString *path = [[NSBundle mainBundle] pathForResource:@"point3@2x" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40, label.frame.size.height+label.frame.origin.y, self.view.frame.size.width - 80, 120)];
        [slider setBackgroundColor:[UIColor clearColor]];
        [slider setMaximumTrackTintColor:[UIColor grayColor]];
        [slider setMinimumTrackTintColor:RGB(0x13, 0xb3, 0x5c)];
        [slider setMaximumValue:3.0f];
        [slider setMinimumValue:1.0f];
        [slider setValue:appDelegate.currentAirInfo.gearState];
        path = [[NSBundle mainBundle] pathForResource:@"seekbar_btn@2x" ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:path];
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
    [self.navigationController pushViewController:filterInfoViewController animated:YES];
}

//风速按钮点击
-(void)speedButtonClick:(UIButton *)button
{
    //如果儿童锁按钮点击，那么提示信息
    if(_childLockButton.selected)
    {
        //提示信息
        [self.view makeToast:NSLocalizedString(@"childMessage", nil) duration:0.8 position:@"bottom"];
        return;
    }
    //如果自动按钮点击，那么提示信息
   else if(_handOrAutoButton.selected)
    {
        //提示信息
        [self.view makeToast:NSLocalizedString(@"autoMessage", nil) duration:0.8 position:@"bottom"];
        return;
    }
    else
    {
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
    //关于界面
    BLAboutViewController *aboutViewControl = [[BLAboutViewController alloc] init];
    [self.navigationController pushViewController:aboutViewControl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //插入定时数据
    BLTimerInfomation *timerInfomation = [sqlite getSecondCountTimer];
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
                UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"weather_layout_color_bg@2x.png"]];
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
    //顶部视图
    [self setTopView:nil];
    //温度
    [self setWeatherLabel:nil];
    //点击风速弹出的视图
    [self setBackView:nil];
    //空气质量指数
    [self setAirQualityLabel:nil];
    //开关按钮
    [self setSwitchButton:nil];
    //手动或者自动按钮
    [self setHandOrAutoButton:nil];
    //手动自动标题
    [self setHandOrAutoLabel:nil];
    //睡眠开关标题
    [self setSleepLabel:nil];
    //儿童锁开关标题
    [self setChildLockLabel:nil];
    [self setAddress:nil];
    [self setLeftTimerLabel:nil];
    [self setLocManager:nil];
    [self setGeocoder:nil];
    [_refreshInfoTimer invalidate];
    _refreshInfoTimer = nil;
    [_refreshLocationInfo invalidate];
    _refreshLocationInfo = nil;
    dispatch_release(networkQueue);
    dispatch_release(httpQueue);
}

//自动或者手动按钮点击
- (void)allButtonClicked:(UIButton *)button
{
    //判断是否开机状态
    if(!appDelegate.currentAirInfo.switchStatus && button.tag != 1)
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
            [sendInfo setAutoOrHand:appDelegate.currentAirInfo.autoOrHand];
            sendInfo.sleepState = appDelegate.currentAirInfo.sleepState;
            sendInfo.childLockState = appDelegate.currentAirInfo.childLockState;
        }
        else if (button.tag == 2)
        {
            //自动或者手动按钮
            [sendInfo setAutoOrHand:!button.selected];
            sendInfo.switchStatus = appDelegate.currentAirInfo.switchStatus;
            sendInfo.sleepState = appDelegate.currentAirInfo.sleepState;
            sendInfo.childLockState = appDelegate.currentAirInfo.childLockState;
        }
        else if (button.tag == 3)
        {
            //睡眠按钮
            sendInfo.sleepState = !button.selected;
            sendInfo.switchStatus = appDelegate.currentAirInfo.switchStatus;
            [sendInfo setAutoOrHand:appDelegate.currentAirInfo.autoOrHand];
            sendInfo.childLockState = appDelegate.currentAirInfo.childLockState;
        }
        else if(button.tag == 4)
        {
            //儿童锁按钮
            sendInfo.childLockState = !button.selected;
            sendInfo.switchStatus = appDelegate.currentAirInfo.switchStatus;
            [sendInfo setAutoOrHand:appDelegate.currentAirInfo.autoOrHand];
            sendInfo.sleepState = appDelegate.currentAirInfo.sleepState;
        }
        sendInfo.gearState = appDelegate.currentAirInfo.gearState;
        
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
            appDelegate.currentAirInfo = recvInfo;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *stringSwitchState;
                NSString *stringSwitchClick;
                //判断是那个按钮点击
                if(button.tag == 2)
                {
                    //手动或者自动按钮
                    if(appDelegate.currentAirInfo.autoOrHand)
                    {
                        stringSwitchState = [[NSBundle mainBundle] pathForResource:@"auto_on@2x" ofType:@"png"];
                        stringSwitchClick = [[NSBundle mainBundle] pathForResource:@"auto_on_press@2x" ofType:@"png"];
                        [_handOrAutoLabel setText:NSLocalizedString(@"Automatic", nil)];
                        button.selected = YES;
                    }
                    else
                    {
                        stringSwitchState = [[NSBundle mainBundle] pathForResource:@"hand_on@2x" ofType:@"png"];
                        stringSwitchClick = [[NSBundle mainBundle] pathForResource:@"hand_on_press@2x" ofType:@"png"];
                        [_handOrAutoLabel setText:NSLocalizedString(@"Manual", nil)];
                        button.selected = NO;
                    }
                }
                else if (button.tag == 1)
                {
                    //判断开关按钮
                    if(appDelegate.currentAirInfo.switchStatus)
                    {
                        stringSwitchState = [[NSBundle mainBundle] pathForResource:@"power_on@2x" ofType:@"png"];
                        stringSwitchClick = [[NSBundle mainBundle] pathForResource:@"power_on_press@2x" ofType:@"png"];
                        button.selected = YES;
                    }
                    else
                    {
                        stringSwitchState = [[NSBundle mainBundle] pathForResource:@"power_off@2x" ofType:@"png"];
                        stringSwitchClick = [[NSBundle mainBundle] pathForResource:@"power_off_press@2x" ofType:@"png"];
                        button.selected = NO;
                    }
                }
                else if (button.tag == 3)
                {
                    //判断睡眠按钮
                    if(appDelegate.currentAirInfo.sleepState)
                    {
                        stringSwitchState = [[NSBundle mainBundle] pathForResource:@"night_on@2x" ofType:@"png"];
                        stringSwitchClick = [[NSBundle mainBundle] pathForResource:@"night_on_press@2x" ofType:@"png"];
                        [_sleepLabel setText:NSLocalizedString(@"SleepOn", nil)];
                        button.selected = YES;
                    }
                    else
                    {
                        stringSwitchState = [[NSBundle mainBundle] pathForResource:@"night_off@2x" ofType:@"png"];
                        stringSwitchClick = [[NSBundle mainBundle] pathForResource:@"night_off_press@2x" ofType:@"png"];
                        [_sleepLabel setText:NSLocalizedString(@"SleepOff", nil)];
                        button.selected = NO;
                    }
                }
                else if (button.tag == 4)
                {
                    //判断儿童锁按钮
                    if(appDelegate.currentAirInfo.childLockState)
                    {
                        stringSwitchState = [[NSBundle mainBundle] pathForResource:@"lock_on@2x" ofType:@"png"];
                        stringSwitchClick = [[NSBundle mainBundle] pathForResource:@"lock_on_press@2x" ofType:@"png"];
                        [_childLockLabel setText:NSLocalizedString(@"TheChildLock", nil)];
                        button.selected = YES;
                    }
                    else
                    {
                        stringSwitchState = [[NSBundle mainBundle] pathForResource:@"lock_off@2x" ofType:@"png"];
                        stringSwitchClick = [[NSBundle mainBundle] pathForResource:@"lock_off_press@2x" ofType:@"png"];
                        [_childLockLabel setText:NSLocalizedString(@"TheChildLockOff", nil)];
                        button.selected = NO;
                    }
                }
                UIImage *imageSwitchState = [UIImage imageWithContentsOfFile:stringSwitchState];
                UIImage *imageSwitchClick = [UIImage imageWithContentsOfFile:stringSwitchClick];
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
    //数据透传
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:9000] forKey:@"api_id"];
    [dic setObject:@"passthrough" forKey:@"command"];
    [dic setObject:appDelegate.deviceInfo.mac forKey:@"mac"];
    [dic setObject:@"bytes" forKey:@"format"];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc ]init];
    for (int i = 0; i <= 24; i++)
    {
        if( i == 0)
            [dataArray addObject:[NSNumber numberWithInt:0xfe]];
        else if( i == 1)
            [dataArray addObject:[NSNumber numberWithInt:0x41]];
        else if( i == 4)
            [dataArray addObject:[NSNumber numberWithInt:sendInfo.switchStatus]];
        else if( i == 5)
            [dataArray addObject:[NSNumber numberWithInt:sendInfo.autoOrHand]];
        else if( i == 6)
            [dataArray addObject:[NSNumber numberWithInt:sendInfo.gearState]];
        else if( i == 7)
            [dataArray addObject:[NSNumber numberWithInt:sendInfo.sleepState]];
        else if( i == 8)
            [dataArray addObject:[NSNumber numberWithInt:sendInfo.childLockState]];
        else if( i == 23)
            [dataArray addObject:[NSNumber numberWithInt:0x00]];
        else if( i == 24)
            [dataArray addObject:[NSNumber numberWithInt:0xaa]];
        else
            [dataArray addObject:[NSNumber numberWithInt:0x00]];
    }
    [dic setObject:dataArray forKey:@"data"];
    
    NSData *sendData = [dic JSONData];
    NSLog(@"%@", [dic JSONString]);
    NSData *response = [networkAPI requestDispatch:sendData];
    return response;
}

//根据传入的数组取得接受数据
-(BeiAngReceivedDataInfo *)turnArrayToBeiAngReceivedDataInfo:(NSArray *)array
{
    BeiAngReceivedDataInfo *recvInfo = [[BeiAngReceivedDataInfo alloc] init];
    //设置开关状态: 00 关机  01 打开
    [recvInfo setSwitchStatus:[array[4] intValue]];
    //手动自动状态: 00 手动状态  01 自动状态
    [recvInfo setAutoOrHand:[array[5] intValue]];
    //净化器运行档位状态: 00 0档位 01 1档 0x02 02 2档 03 3档
    [recvInfo setGearState:[array[6] intValue]];
    //睡眠状态: 00 不在睡眠状态  01睡眠状态
    [recvInfo setSleepState:[array[7] intValue]];
    //儿童锁状态: 00 不在儿童锁状态 01儿童锁状态
    [recvInfo setChildLockState:[array[8] intValue]];
    //设备类型: 01：280B。02：280C.03:车载04:AURA100.
    [recvInfo setDeviceType:[array[2] intValue]];
    //电极运行时间: 第一位为小时数
    [recvInfo setRunHours:[array[9] intValue]];
    //电极运行时间:第二位为分钟数(0x13,0x18:19小时24分钟)
    [recvInfo setRunMinutes:[array[10] intValue]];
    //空气质量档位: 01：一档，好。02：二档，中。03：三档，差
    [recvInfo setAirQualityGear:[array[11] intValue]];
    //空气质量原始数据: 数据
    [recvInfo setAirQualityData:[array[12] intValue]];
    [recvInfo setAirQualityDataB:[array[13] intValue]];
    //光照状态: 01：亮，02：昏暗，03：黑
    [recvInfo setLightCondition:[array[14] intValue]];
    //维护状态: 01：清洗电极，02：需要检查电极状态并断电重启
    [recvInfo setMaintenancesState:[array[15] intValue]];
    //温度: 带符号数：-127~127(0x8c:-12℃,0x12:18℃)
    [recvInfo setTemperature:[array[16] intValue]];
    //湿度: 不带符号数，0~100(0x39:57%)
    [recvInfo setHumidity:[array[17] intValue]];
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
    UISlider* s = (UISlider*)g.view;
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
        sendInfo.childLockState = appDelegate.currentAirInfo.childLockState;
        sendInfo.switchStatus = appDelegate.currentAirInfo.switchStatus;
        [sendInfo setAutoOrHand:appDelegate.currentAirInfo.autoOrHand];
        sendInfo.sleepState = appDelegate.currentAirInfo.sleepState;
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
            appDelegate.currentAirInfo = recvInfo;
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

#pragma mark -
#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //有数据的场合停止检索
    NSLog(@"_weatherLabel = %d",_weatherLabel.text.length);
    if(_weatherLabel.text.length > 0)
    {
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
            @synchronized(appDelegate.airQualityInfoClass)
            {
                //城市名称
                appDelegate.airQualityInfoClass.cityName = [[[placemark.addressDictionary objectForKey:@"City"] componentsSeparatedByString:@"市"] objectAtIndex:0];
                _address.text = appDelegate.airQualityInfoClass.cityName;
                //城市code
                appDelegate.airQualityInfoClass.cityCode = [[appDelegate.cityCodeStrings objectFromJSONString] objectForKey:[[appDelegate.airQualityInfoClass.cityName componentsSeparatedByString:@"市"] objectAtIndex:0]];
                NSLog(@"cityCode = %d",appDelegate.airQualityInfoClass.cityCode.length);
                //如果名称不相同则一般为英文
                //取得空气质量
                if(appDelegate.airQualityInfoClass.cityCode.length > 0)
                {
                    //定时
                    _refreshLocationInfo = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getWeather) userInfo:nil repeats:YES];
                    [_refreshLocationInfo fire];
                }
                else
                {
                    //定时
                    _refreshLocationInfo = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getCityInfo) userInfo:nil repeats:YES];
                    [_refreshLocationInfo fire];
                    NSLog(@"_airQualityInfoClass.cityName = %@",appDelegate.airQualityInfoClass.cityName);
                }
            }
        }
        else if (error == nil && [placemarks count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
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
        @synchronized(appDelegate.airQualityInfoClass)
        {
            appDelegate.airQualityInfoClass.cityName = [[[[weatherInfo objectForKey:@"addressComponent"] objectForKey:@"city"] componentsSeparatedByString:@"市"] objectAtIndex:0];
            _address.text = appDelegate.airQualityInfoClass.cityName;
            //城市code
            appDelegate.airQualityInfoClass.cityCode = [[appDelegate.cityCodeStrings objectFromJSONString] objectForKey:[[appDelegate.airQualityInfoClass.cityName componentsSeparatedByString:@"市"] objectAtIndex:0]];
            if(appDelegate.airQualityInfoClass.cityCode.length > 0)
            {
                //定时
                _refreshLocationInfo = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(getWeather) userInfo:nil repeats:YES];
                [_refreshLocationInfo fire];
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
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tqapi.mobile.360.cn/app/meizu/city/%@",appDelegate.airQualityInfoClass.cityCode]];
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
                    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"weather_layout_color_bg@2x.png"]];
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
