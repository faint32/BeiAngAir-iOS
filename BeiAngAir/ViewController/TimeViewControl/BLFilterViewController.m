//
//  BLFilterViewController.m
//  TableAir
//
//  Created by hqb on 14-5-27.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import "BLFilterViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "CustomNaviBarView.h"
#import "BLAppDelegate.h"
#import "BeiAngNetwork.h"
#import "BLFMDBSqlite.h"
#import "PICircularProgressView.h"
#import "Toast+UIView.h"
#import "MMProgressHUD.h"
#import "iCarousel.h"
#import "BLZSIndicatorProgress.h"

@interface BLFilterViewController ()<iCarouselDataSource, iCarouselDelegate>
{
    //-- count time 事件选择器
    iCarousel *iMinPickerFrom;
    iCarousel *iHourPickerFrom;
    dispatch_queue_t networkQueue;
    BeiAngNetworkUnit *networkAPI;
    BLAppDelegate *appDelegate;
    //两个选择的
    BLZSIndicatorProgress *countDownHourIndicator;
    BLZSIndicatorProgress *countDownMiniteIndicator;
}
@property(nonatomic, strong) UIButton *buttonCancel;
@property(nonatomic, strong) UIButton *buttonClose;
@property(nonatomic, strong) UIImageView *imageViewCancel;
@property(nonatomic, strong) UIImageView *imageViewClose;
@property(nonatomic, strong) UIView *selectedView;
@property(nonatomic, strong) UIButton *lastSelectedButton;
@property(nonatomic, strong) UILabel *labelCancel;
@property(nonatomic, strong) UILabel *labelClose;
@property(nonatomic, strong) UILabel *labelSelected;
@end

@implementation BLFilterViewController

- (void)dealloc
{
    dispatch_release(networkQueue);
    _buttonCancel = nil;
    _buttonClose = nil;
    _imageViewCancel = nil;
    _imageViewClose = nil;
    _selectedView = nil;
    _lastSelectedButton = nil;
    _labelCancel = nil;
    _labelClose = nil;
    _labelSelected = nil;
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
	// Do any additional setup after loading the view.
    networkQueue = dispatch_queue_create("BLFilterViewController", DISPATCH_QUEUE_SERIAL);
    networkAPI = [BeiAngNetworkUnit sharedNetworkAPI];
    appDelegate = (BLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //页面设置
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    [self.navigationController setToolbarHidden:YES];
    CGRect viewFrame = CGRectZero;
    
    //返回按钮
    NSString *path = [[NSBundle mainBundle] pathForResource:@"return@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    viewFrame.origin.x = 0;
    viewFrame.origin.y = 20.f;
    viewFrame.size.width = image.size.width;
    viewFrame.size.height = image.size.height;
    UIButton *returnButton = [[UIButton alloc] initWithFrame:viewFrame];
    returnButton.backgroundColor = [UIColor clearColor];
    [returnButton setImage:image forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(returnButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnButton];
    
    //设置标题
    viewFrame.origin.x = returnButton.frame.origin.x;
    viewFrame.origin.y = 20.f;
    viewFrame.size.width = self.view.frame.size.width - 2 * returnButton.frame.size.width;
    viewFrame.size.height = returnButton.frame.size.height;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setNumberOfLines:1];
    [titleLabel setText:NSLocalizedString(@"timerTitle", nil)];
    [titleLabel setTextColor:RGB(0, 145, 241)];
    [self.view addSubview:titleLabel];
    
    //保存
    viewFrame.origin.x = self.view.frame.size.width - 50;
    viewFrame.origin.y = 20.f;
    viewFrame.size.width = 50;
    viewFrame.size.height = image.size.height;
    UIButton *rightButton = [[UIButton alloc] initWithFrame:viewFrame];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    [rightButton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    [rightButton setTitleColor:RGB(0, 145, 241) forState:UIControlStateNormal];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    [rightButton addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
    
    //定时取消
    viewFrame.origin.x = 0;
    viewFrame.origin.y = rightButton.frame.size.height + rightButton.frame.origin.y;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = 60.f;
    _buttonCancel = [[UIButton alloc] initWithFrame:viewFrame];
    [_buttonCancel setBackgroundColor:[UIColor whiteColor]];
    [_buttonCancel setTag:1];
    //定时取消图标
    path = [[NSBundle mainBundle] pathForResource:@"btn_check@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    //定时取消文字
    viewFrame.origin.x = 10;
    viewFrame.origin.y = (60 - image.size.height) / 2.f;
    viewFrame.size.width = 120;
    viewFrame.size.height = image.size.height;
    _labelCancel = [[UILabel alloc] initWithFrame:viewFrame];
    [_labelCancel setText:NSLocalizedString(@"timeCancel", nil)];
    [_labelCancel setBackgroundColor:[UIColor clearColor]];
    [_buttonCancel addSubview:_labelCancel];
    //右边的图片
    viewFrame.origin.x = self.view.frame.size.width - image.size.width - 10;
    viewFrame.origin.y = (_buttonCancel.frame.size.height - image.size.height) / 2.f;
    viewFrame.size.width = image.size.width;
    viewFrame.size.height = image.size.height;
    _imageViewCancel = [[UIImageView alloc] initWithFrame:viewFrame];
    _imageViewCancel.image = image;
    [_buttonCancel addSubview:_imageViewCancel];
    [_buttonCancel addTarget:self action:@selector(cancelOrCloseClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonCancel];
    
    //定时关机
    viewFrame.origin.x = 0;
    viewFrame.origin.y = _buttonCancel.frame.size.height + _buttonCancel.frame.origin.y + 1.f;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = 60.f;
    _buttonClose = [[UIButton alloc] initWithFrame:viewFrame];
    [_buttonClose setBackgroundColor:[UIColor whiteColor]];
    //定时关机文字
    viewFrame.origin.x = 10;
    viewFrame.origin.y = (60 - image.size.height) / 2.f;
    viewFrame.size.width =120;
    viewFrame.size.height = image.size.height;
    _labelClose= [[UILabel alloc] initWithFrame:viewFrame];
    [_labelClose setText:NSLocalizedString(@"timeClose", nil)];
    [_labelClose setBackgroundColor:[UIColor clearColor]];
    [_buttonClose addSubview:_labelClose];
    [_buttonClose setTag:2];
    //定时关机图标
    path = [[NSBundle mainBundle] pathForResource:@"btn_point@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame.origin.x = self.view.frame.size.width - image.size.width - 10;
    viewFrame.origin.y = (_buttonClose.frame.size.height - image.size.height) / 2.f;
    viewFrame.size.width = image.size.width;
    viewFrame.size.height = image.size.height;
    _imageViewClose = [[UIImageView alloc] initWithFrame:viewFrame];
    _imageViewClose.image = image;
    [_buttonClose addSubview:_imageViewClose];
    [_buttonClose addTarget:self action:@selector(cancelOrCloseClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonClose];
    
    //其余空白部分
    viewFrame.origin.x = 30;
    viewFrame.origin.y = _buttonClose.frame.size.height + _buttonClose.frame.origin.y + 20;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = self.view.frame.size.height - (_buttonClose.frame.size.height + _buttonClose.frame.origin.y + 20);
    _selectedView = [[UIView alloc] initWithFrame:viewFrame];
    _selectedView.backgroundColor = [UIColor clearColor];
    // 标签标题
    viewFrame.origin.x=0;
    viewFrame.origin.y=_labelClose.frame.origin.y+_labelClose.frame.size.height+20.f;
    viewFrame.size.width=self.view.frame.size.width;
    viewFrame.size.height=20;
    _labelSelected = [[UILabel alloc] initWithFrame:viewFrame];
    [_labelSelected setBackgroundColor:[UIColor clearColor]];
    NSLog(@"currentAirInfo = %d",appDelegate.currentAirInfo.runHours);
    _labelSelected.text = [NSString stringWithFormat:@"%d%@%d%@%@",appDelegate.currentAirInfo.runHours,NSLocalizedString(@"hour", nil),appDelegate.currentAirInfo.runHours,NSLocalizedString(@"minute", nil),NSLocalizedString(@"close", nil)];
    [_labelSelected setTextAlignment:NSTextAlignmentCenter];
    [_labelSelected setTextColor:[UIColor blackColor]];
    [_labelSelected setFont:[UIFont systemFontOfSize:11.f]];
    [_selectedView addSubview:_labelSelected];
    //选取
    viewFrame.origin.x=0;
    viewFrame.origin.y=_labelSelected.frame.origin.y+_labelSelected.frame.size.height+10.f;
    viewFrame.size.width=80;
    viewFrame.size.height=180;
    iHourPickerFrom = [[iCarousel alloc] initWithFrame:viewFrame];
    [iHourPickerFrom setBackgroundColor:[UIColor clearColor]];
    [iHourPickerFrom setDelegate:self];
    [iHourPickerFrom setDataSource:self];
    [iHourPickerFrom setType:iCarouselTypeLinear];
    [iHourPickerFrom setVertical:YES];
    [iHourPickerFrom setClipsToBounds:YES];
    [iHourPickerFrom setDecelerationRate:.91f];
    if(appDelegate.currentAirInfo.runHours)
        [iHourPickerFrom scrollToItemAtIndex:appDelegate.currentAirInfo.runHours animated:NO];
    else
        [iHourPickerFrom scrollToItemAtIndex:0 animated:NO];
    [_selectedView addSubview:iHourPickerFrom];
    //分隔符
    viewFrame.origin.x=iHourPickerFrom.frame.origin.x+iHourPickerFrom.frame.size.width+10.f;
    viewFrame.origin.y=iHourPickerFrom.frame.origin.y+(iHourPickerFrom.frame.size.height)/2.0f-8.f;
    viewFrame.size.width=40;
    viewFrame.size.height=20;
    UILabel *label = [[UILabel alloc]initWithFrame:viewFrame];
    [label setTextColor:[UIColor colorWithRed:61.f/255.f green:57.f/255.f blue:53.f/255.f alpha:1]];
    [label setText:NSLocalizedString(@"hour", nil)];
    [label setBackgroundColor:[UIColor clearColor]];
    [_selectedView addSubview:label];
    
    //选取
    viewFrame.origin.x=label.frame.size.width+label.frame.origin.x+1.f;
    viewFrame.origin.y=iHourPickerFrom.frame.origin.y;
    viewFrame.size.width=iHourPickerFrom.frame.size.width;
    viewFrame.size.height=iHourPickerFrom.frame.size.height;
    iMinPickerFrom = [[iCarousel alloc] initWithFrame:viewFrame];
    [iMinPickerFrom setBackgroundColor:[UIColor clearColor]];
    [iMinPickerFrom setDelegate:self];
    [iMinPickerFrom setDataSource:self];
    [iMinPickerFrom setType:iCarouselTypeLinear];
    [iMinPickerFrom setVertical:YES];
    [iMinPickerFrom setClipsToBounds:YES];
    [iMinPickerFrom setDecelerationRate:.99f];
    if(appDelegate.currentAirInfo.runHours)
        [iMinPickerFrom scrollToItemAtIndex:appDelegate.currentAirInfo.runHours animated:NO];
    else
        [iMinPickerFrom scrollToItemAtIndex:0 animated:NO];
    [_selectedView addSubview:iMinPickerFrom];
    //分隔符
    viewFrame.origin.x=iMinPickerFrom.frame.origin.x+iHourPickerFrom.frame.size.width+10.f;
    viewFrame.origin.y=label.frame.origin.y;
    viewFrame.size=label.frame.size;
    label = [[UILabel alloc]initWithFrame:viewFrame];
    [label setTextColor:[UIColor colorWithRed:61.f/255.f green:57.f/255.f blue:53.f/255.f alpha:1]];
    [label setText:NSLocalizedString(@"minute", nil)];
    [label setBackgroundColor:[UIColor clearColor]];
    [_selectedView addSubview:label];
    [self.view addSubview:_selectedView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *pathCheck = [[NSBundle mainBundle] pathForResource:@"btn_check@2x" ofType:@"png"];
    UIImage *imageCheck = [UIImage imageWithContentsOfFile:pathCheck];
    NSString *pathUnCheck = [[NSBundle mainBundle] pathForResource:@"btn_point@2x" ofType:@"png"];
    UIImage *imageUnCheck = [UIImage imageWithContentsOfFile:pathUnCheck];
    //判断当前是那个按钮选择s
    if(appDelegate.currentAirInfo.runHours)
    {
        _lastSelectedButton = _buttonClose;
        //有定时
        _selectedView.hidden = NO;
        [_labelCancel setTextColor:[UIColor blackColor]];
        [_labelClose setTextColor:RGB(0, 145, 241)];
        //取消按钮
        _imageViewClose .image = imageCheck;
        CGRect viewFrame =_imageViewClose.frame;
        viewFrame.origin.x = self.view.frame.size.width - imageCheck.size.width - 10;
        viewFrame.size = imageCheck.size;
        [_imageViewClose setFrame:viewFrame];
        
        //关闭按钮
        _imageViewCancel.image = imageUnCheck;
        viewFrame =_imageViewCancel.frame;
        viewFrame.origin.x = self.view.frame.size.width - imageUnCheck.size.width - 10;
        viewFrame.size = imageUnCheck.size;
        [_imageViewCancel setFrame:viewFrame];
    }
    else
    {
        _lastSelectedButton = _buttonCancel;
        //无定时
        _selectedView.hidden = YES;
        [_labelClose setTextColor:[UIColor blackColor]];
        [_labelCancel setTextColor:RGB(0, 145, 241)];
        //取消按钮
        _imageViewCancel .image = imageCheck;
        CGRect viewFrame =_imageViewCancel.frame;
        viewFrame.origin.x = self.view.frame.size.width - imageCheck.size.width - 10;
        viewFrame.size = imageCheck.size;
        [_imageViewCancel setFrame:viewFrame];
        
        //关闭按钮
        _imageViewClose.image = imageUnCheck;
        viewFrame =_imageViewClose.frame;
        viewFrame.origin.x = self.view.frame.size.width - imageUnCheck.size.width - 10;
        viewFrame.size = imageUnCheck.size;
        [_imageViewClose setFrame:viewFrame];
    }
}

//保存按钮点击
-(void)saveButtonClick
{
    //实例
    BeiAngSendDataInfo *tmpInfo = [[BeiAngSendDataInfo alloc] init];
    //判断点击的按钮
    if(_lastSelectedButton == _buttonCancel)
    {
        NSLog(@"_buttonCancel");
        //定时任务清空
        tmpInfo.switchStatus = 1;
        tmpInfo.autoOrHand = appDelegate.currentAirInfo.autoOrHand;
        tmpInfo.gearState = appDelegate.currentAirInfo.gearState;
        tmpInfo.sleepState = appDelegate.currentAirInfo.sleepState;
        tmpInfo.childLockState = appDelegate.currentAirInfo.childLockState;
        
//        tmpInfo.timer = 0;
//        tmpInfo.lastTime = 0;
//        tmpInfo.temperature = appDelegate.deviceBiluInfo.temperature;
//        tmpInfo.heatingSwitch = appDelegate.deviceBiluInfo.heatingSwitch;
//        tmpInfo.flameColor = appDelegate.deviceBiluInfo.flameColor;
//        tmpInfo.sideFlameColor = appDelegate.deviceBiluInfo.sideFlameColor;
//        tmpInfo.motorSpeed = appDelegate.deviceBiluInfo.motorSpeed;
//        tmpInfo.light = appDelegate.deviceBiluInfo.light;
//        tmpInfo.timerExist = 0;
    }
    else if (_lastSelectedButton == _buttonClose)
    {
        NSLog(@"_buttonClose");
        //定时任务设置
        tmpInfo.switchStatus = 1;
        tmpInfo.autoOrHand = appDelegate.currentAirInfo.autoOrHand;
        tmpInfo.gearState = appDelegate.currentAirInfo.gearState;
        tmpInfo.sleepState = appDelegate.currentAirInfo.sleepState;
        tmpInfo.childLockState = appDelegate.currentAirInfo.childLockState;
    }
    //发送数据
    dispatch_async(networkQueue, ^{
//        [MMProgressHUD showWithTitle:NSLocalizedString(@"Network", nil) status:NSLocalizedString(@"Network", nil)];
        int result;
        BeiAngReceivedDataInfo *tmpReceivedInfo = [networkAPI tclSendDataWithMac:appDelegate.deviceInfo.info.mac sendData:tmpInfo result:&result];
        if (result == 0)    //If success
        {
//            [MMProgressHUD dismiss];
            dispatch_async(dispatch_get_main_queue(), ^{
                appDelegate.currentAirInfo = tmpReceivedInfo;
                //返回上一页
                [self returnButtonClick];
            });
        }
        else    //Control failed
        {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [MMProgressHUD dismiss];
                NSString *message = [appDelegate getErrorStringWithErrno:result];
                [self.view makeToast:message duration:0 position:@"bottom"];
            });
        }
    });
}

//返回按钮点击事件
-(void)returnButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

//取消按钮点击
-(void)cancelOrCloseClick:(UIButton *)button
{
    //判断没有点击
    if(_lastSelectedButton.tag == button.tag)
        return;
    NSString *pathCheck = [[NSBundle mainBundle] pathForResource:@"btn_check@2x" ofType:@"png"];
    UIImage *imageCheck = [UIImage imageWithContentsOfFile:pathCheck];
    NSString *pathUnCheck = [[NSBundle mainBundle] pathForResource:@"btn_point@2x" ofType:@"png"];
    UIImage *imageUnCheck = [UIImage imageWithContentsOfFile:pathUnCheck];
    //判断点击的按钮
    if(button.tag == 1)
    {
        //选择的隐藏
        _selectedView.hidden = YES;
        [_labelClose setTextColor:[UIColor blackColor]];
        [_labelCancel setTextColor:RGB(0, 145, 241)];
        //取消按钮
        _imageViewCancel .image = imageCheck;
        CGRect viewFrame =_imageViewCancel.frame;
        viewFrame.origin.x = self.view.frame.size.width - imageCheck.size.width - 10;
        viewFrame.size = imageCheck.size;
        [_imageViewCancel setFrame:viewFrame];
        
        //关闭按钮
        _imageViewClose.image = imageUnCheck;
        viewFrame =_imageViewClose.frame;
        viewFrame.origin.x = self.view.frame.size.width - imageUnCheck.size.width - 10;
        viewFrame.size = imageUnCheck.size;
        [_imageViewClose setFrame:viewFrame];
    }
    else if (button.tag == 2)
    {
         //选择的显示
        _selectedView.hidden = NO;
        [_labelCancel setTextColor:[UIColor blackColor]];
        [_labelClose setTextColor:RGB(0, 145, 241)];
        //取消按钮
        _imageViewClose .image = imageCheck;
        CGRect viewFrame =_imageViewClose.frame;
        viewFrame.origin.x = self.view.frame.size.width - imageCheck.size.width - 10;
        viewFrame.size = imageCheck.size;
        [_imageViewClose setFrame:viewFrame];
        
        //关闭按钮
        _imageViewCancel.image = imageUnCheck;
        viewFrame =_imageViewCancel.frame;
        viewFrame.origin.x = self.view.frame.size.width - imageUnCheck.size.width - 10;
        viewFrame.size = imageUnCheck.size;
        [_imageViewCancel setFrame:viewFrame];
    }
    //选择按钮隐藏
    _lastSelectedButton = button;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    return 3;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    return 3;
}

- (void)carouselCurrentItemIndexUpdated:(iCarousel *)carousel
{
    int index2 = carousel.currentItemIndex;
    int index3 = carousel.currentItemIndex + 1;
    NSMutableArray *itemArray = (NSMutableArray *)carousel.visibleItemViews;
    UILabel *label1 = [itemArray objectAtIndex:0];
    UILabel *label2 = [itemArray objectAtIndex:1];
    UILabel *label3 = [itemArray objectAtIndex:2];
    if ([carousel isEqual:iHourPickerFrom])
    {
        
        if (index3 > 15)
        {
            label1.textColor = [UIColor lightGrayColor];
            label1.font = [UIFont systemFontOfSize:20.0f];
            label2.textColor = [UIColor lightGrayColor];
            label2.font = [UIFont systemFontOfSize:20.0f];
            label3.textColor = [UIColor blackColor];
            label3.font = [UIFont systemFontOfSize:45.0f];
        }
        else if (index2 == 0)
        {
            label1.textColor = [UIColor blackColor];
            label1.font = [UIFont systemFontOfSize:45.0f];
            label2.textColor = [UIColor lightGrayColor];
            label2.font = [UIFont systemFontOfSize:20.0f];
            label3.textColor = [UIColor lightGrayColor];
            label3.font = [UIFont systemFontOfSize:20.0f];
        }
        else
        {
            label1.textColor = [UIColor lightGrayColor];
            label1.font = [UIFont systemFontOfSize:20.0f];
            label2.textColor = [UIColor blackColor];
            label2.font = [UIFont systemFontOfSize:45.0f];
            label3.textColor = [UIColor lightGrayColor];
            label3.font = [UIFont systemFontOfSize:20.0f];
        }
    }
    
    if ([carousel isEqual:iMinPickerFrom])
    {
        if (index3 > 59)
        {
            label1.textColor = [UIColor lightGrayColor];
            label1.font = [UIFont systemFontOfSize:20.0f];
            label2.textColor = [UIColor lightGrayColor];
            label2.font = [UIFont systemFontOfSize:20.0f];
            label3.textColor = [UIColor blackColor];
            label3.font = [UIFont systemFontOfSize:45.0f];
        }
        else if (index2 == 0)
        {
            label1.textColor = [UIColor blackColor];
            label1.font = [UIFont systemFontOfSize:45.0f];
            label2.textColor = [UIColor lightGrayColor];
            label2.font = [UIFont systemFontOfSize:20.0f];
            label3.textColor = [UIColor lightGrayColor];
            label3.font = [UIFont systemFontOfSize:20.0f];
        }
        else
        {
            label1.textColor = [UIColor lightGrayColor];
            label1.font = [UIFont systemFontOfSize:20.0f];
            label2.textColor = [UIColor blackColor];
            label2.font = [UIFont systemFontOfSize:45.0f];
            label3.textColor = [UIColor lightGrayColor];
            label3.font = [UIFont systemFontOfSize:20.0f];
        }
    }
    
    //-- 获取每个iCarousel的值
    [countDownHourIndicator setPercent:iHourPickerFrom.currentItemIndex maxPercent:24 animated:YES];
    [countDownMiniteIndicator setPercent:iMinPickerFrom.currentItemIndex maxPercent:60 animated:YES];
    [_labelSelected setBackgroundColor:[UIColor clearColor]];
    _labelSelected.text = [NSString stringWithFormat:@"%d%@%d%@%@",iHourPickerFrom.currentItemIndex,NSLocalizedString(@"hour", nil),iMinPickerFrom.currentItemIndex,NSLocalizedString(@"minute", nil),NSLocalizedString(@"close", nil)];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil)
	{
        view = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, carousel.frame.size.width, carousel.frame.size.height)];
    }
    
    ((UILabel *)view).textAlignment = NSTextAlignmentCenter;
    ((UILabel *)view).font = [UIFont systemFontOfSize:11.0f];
    ((UILabel *)view).textColor = [UIColor lightGrayColor];
    ((UILabel *)view).backgroundColor = [UIColor clearColor];
    
    ((UILabel *)view).text = [NSString stringWithFormat:@"%02i", index];
    
    return view;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return carousel.frame.size.width;
}

//必须的方法
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    NSUInteger count = 0;
    if ([carousel isEqual:iHourPickerFrom] )
    {
        count = 16;
    }
    else if ([carousel isEqual:iMinPickerFrom])
    {
        count = 60;
    }
    return count;
}

- (CGFloat)carousel:(iCarousel *)carousel itemAlphaForOffset:(CGFloat)offset
{
	//set opacity based on distance from camera
    return 1.0f - fminf(fmaxf(offset, 0.0f), 1.0f);
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * _carousel.itemWidth);
    //    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * _carousel.itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return YES;
}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
    return YES;
}
@end
