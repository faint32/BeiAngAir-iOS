//
//  BLDeviceListViewController.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceListViewController.h"
#import "GlobalDefine.h"
#import "BLModuleInfomation.h"
#import "BLSmartConfigViewController.h"
#import "BLAppDelegate.h"
#import "BLNetwork.h"
#import "BLFMDBSqlite.h"
#import "EGORefreshTableHeaderView.h"
#import "Toast+UIView.h"
#import "BLAirQualityViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "BLDeviceInfoEditViewController.h"
#import "CustomNaviBarView.h"
#import "MMProgressHUD.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import "BLCustomHUD+UIWindow.h"
#import "CustomNavigationController.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface BLAirQualityInfo : NSObject

@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int sleepState;
@property (nonatomic, assign) int switchState;
@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation BLAirQualityInfo

- (void)dealloc
{
    [super dealloc];
    [self setMac:nil];
    [self setHour:0];
    [self setMinute:0];
    [self setSleepState:0];
    [self setSwitchState:0];
    [self setIsRefresh:NO];
}

@end

@interface BLDeviceListViewController () <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    BLAppDelegate *appDelegate;
    BLFMDBSqlite *sqlite;
    dispatch_queue_t networkQueue;
    
    EGORefreshTableHeaderView *_refreshTableView;  
    BOOL _reloading;
}
@property (nonatomic, strong) BLNetwork *networkAPI;
//@property (nonatomic, strong) BeiAngNetworkUnit *beiAngAirNetwork;
@property (nonatomic, strong) UITableView *tableView;
/*Refresh device list timer*/
@property (nonatomic, strong) NSTimer *refreshTimer;
/*Device status array.*/
@property (nonatomic, strong) NSMutableArray *statusArray;
@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation BLDeviceListViewController

- (void)dealloc
{
    [super dealloc];
    [self setTableView:nil];
    [self setStatusArray:nil];
    _networkAPI = nil;
//    _beiAngAirNetwork = nil;
    dispatch_release(networkQueue);
    [_refreshTimer invalidate];
    _refreshTimer = nil;
    _deviceArray = nil;
    _statusArray = nil;
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
    _networkAPI = [[BLNetwork alloc] init];
//    _beiAngAirNetwork = [BeiAngNetworkUnit sharedNetworkAPI];
    sqlite = [BLFMDBSqlite sharedFMDBSqlite];
    networkQueue = dispatch_queue_create("BLDeviceListViewControllerNetworkQueue", DISPATCH_QUEUE_SERIAL);
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    _deviceArray = [[NSMutableArray alloc] init];
    NSMutableArray *muTableArray = [[NSMutableArray alloc] initWithArray:[sqlite getAllModuleInfo]];
    NSLog(@"muTableArray = %d",muTableArray.count);
    for (BLModuleInfomation *tmp in muTableArray) {
        BLDeviceInfo *deviceInfo = tmp.info;
        [_deviceArray addObject:deviceInfo];
    }
    _statusArray = [[NSMutableArray alloc] init];
    //背景颜色
    [self.view setBackgroundColor:RGB(246.0f, 246.0f, 246.0f)];
    
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = 0.0f;
    viewFrame.origin.y = 0.0f;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = 44.0f + ((IsiOS7Later) ? 20.0f : 0.0f);
    UIView *headerView = [[UIView alloc] initWithFrame:viewFrame];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:headerView];
    
    viewFrame = headerView.frame;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [titleLabel setTextColor:RGB(0x13, 0xb3, 0x5c)];
    [titleLabel setText:NSLocalizedString(@"DeviceListViewControllerTitle", nil)];
    viewFrame = [titleLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.x = (headerView.frame.size.width - viewFrame.size.width) * 0.5f;
    viewFrame.origin.y = (44.0f - viewFrame.size.height) * 0.5f + ((IsiOS7Later) ? 20.0f : 0.0f);
    [titleLabel setFrame:viewFrame];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:titleLabel];
    
    //底部的添加设备
    UIButton *btnAddDevice=[[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-43, self.view.frame.size.width, 43)];
    //button(ALL,Senior,Ordinary)显示数据
    //背景颜色
    btnAddDevice.backgroundColor=[UIColor whiteColor];
    //button增加方法
    [btnAddDevice addTarget:self action:@selector(addNewDevice) forControlEvents:UIControlEventTouchUpInside];
    viewFrame.origin.x = self.view.frame.size.width / 2.f - 70;
    viewFrame.origin.y = 0;
    viewFrame.size.width = 80;
    viewFrame.size.height = 43;
    UILabel *label = [[UILabel alloc] initWithFrame:viewFrame];
    [label setText:NSLocalizedString(@"DeviceListViewControllerAddText", nil)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:1];
    [label setTextColor:RGB(0x13, 0xb3, 0x5c)];
    CGSize size = [NSLocalizedString(@"DeviceListViewControllerAddText", nil) sizeWithFont:label.font constrainedToSize:CGSizeMake(MAXFLOAT, label.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    viewFrame.origin.x = self.view.frame.size.width / 2.f - size.width / 2.f - 5.f;
    viewFrame.size.width = size.width;
    [label setFrame:viewFrame];
    [btnAddDevice addSubview:label];
    //图片
    NSString *path = [[NSBundle mainBundle] pathForResource:@"enter@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    viewFrame.origin.x = label.frame.size.width + label.frame.origin.x + 5;
    viewFrame.origin.y = (btnAddDevice.frame.size.height - image.size.height) / 2.f;
    viewFrame.size.width = image.size.width;
    viewFrame.size.height = image.size.height;
    UIImageView *addImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    addImageView.image = image;
    [btnAddDevice addSubview:addImageView];
    //加入显示
    [self.view addSubview:btnAddDevice];
  
    /*Add device list.*/
    viewFrame = CGRectZero;
    viewFrame.origin.y = headerView.frame.origin.y + headerView.frame.size.height;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = self.view.frame.size.height - viewFrame.origin.y - 44.0f;
    _tableView = [[UITableView alloc] initWithFrame:viewFrame style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView.layer setBorderColor:RGBA(0x00, 0x00, 0x00, 0.3f).CGColor];
    [_tableView.layer setBorderWidth:0.5f];
    [self setExtraCellLineHidden:_tableView];
    [self.view addSubview:_tableView];
    
    if (_refreshTableView == nil) {  
        //初始化下拉刷新控件  
        EGORefreshTableHeaderView *refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, _tableView.frame.size.width, _tableView.bounds.size.height)];  
        refreshView.delegate = self;  
        //将下拉刷新控件作为子控件添加到_tableView中  
        [_tableView addSubview:refreshView];  
        _refreshTableView = refreshView;  
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(refreshDeviceList) userInfo:nil repeats:YES];
    [_refreshTimer fire];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (void)addNewDevice
{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
    BLSmartConfigViewController *vc = [[BLSmartConfigViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

/*Refresh Device List.*/
- (void)refreshDeviceList
{
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:11] forKey:@"api_id"];
        [dic setObject:@"probe_list" forKey:@"command"];
        NSData *sendData = [dic JSONData];
        
        /*Send data*/
        NSData *response = [_networkAPI requestDispatch:sendData];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        if (code == 0)
        {
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_deviceArray];
            NSArray *list = [[response objectFromJSONData] objectForKey:@"list"];
            int count = list.count;
            NSLog(@"count = %d",count);
            for (int i=0; i<count; i++)
            {
                BLDeviceInfo *info = [[BLDeviceInfo alloc] init];
                NSDictionary *item = [list objectAtIndex:i];
                [info setMac:[item objectForKey:@"mac"]];
                [info setType:[item objectForKey:@"type"]];
                [info setName:[item objectForKey:@"name"]];
                [info setLock:[[item objectForKey:@"lock"] intValue]];
                [info setPassword:[[item objectForKey:@"password"] unsignedIntValue]];
                [info setTerminal_id:[[item objectForKey:@"id"] intValue]];
                [info setSub_device:[[item objectForKey:@"subdevice"] intValue]];
                [info setKey:[item objectForKey:@"key"]];
                /*Add this device to network thread.*/
                //判断是否重复的数据
                BOOL tmp = NO;
                for (int j = 0; j < array.count; j++) {
                    BLDeviceInfo *infoTmp = [array objectAtIndex:j];
                    if(infoTmp.mac == info.mac)
                    {
                        tmp = YES;
                        if(![infoTmp.name isEqualToString:info.name] || infoTmp.lock != info.lock)
                        {
                            [array replaceObjectAtIndex:j withObject:info];
                            BLModuleInfomation *moduleInfomation = [[BLModuleInfomation alloc] init];
                            moduleInfomation.info = info;
                            [sqlite insertOrUpdateModuleInfo:moduleInfomation];
                        }
                        break;
                    }
                }
                NSLog(@"mac = %@",info.mac);
                //不存在的场合
                if(!tmp)
                {
                    //加入数据库
                    [self getNewModuleInfo:info];
                    [self addDeviceInfo:info];
                    [array addObject:info];
                }
                
                //添加到设备信息列表中
                @synchronized(_statusArray)
                {
                    BOOL exist = NO;
                    for (int j=0; j<_statusArray.count; j++)
                    {
                        BLAirQualityInfo *stInfo = [_statusArray objectAtIndex:j];
                        if ([stInfo.mac isEqualToString:info.mac])
                        {
                            exist = YES;
                            break;
                        }
                    }
                    if(!exist)
                    {
                        BLAirQualityInfo *stInfo = [[BLAirQualityInfo alloc] init];
                        [stInfo setMac:info.mac];
                        [stInfo setHour:0];
                        [stInfo setSleepState:0];
                        [stInfo setMinute:0];
                        [stInfo setSwitchState:0];
                        [stInfo setIsRefresh:NO];
                        [_statusArray addObject:stInfo];
                    }
                }
            }
            /*Refresh tableView*/
            dispatch_async(dispatch_get_main_queue(), ^{
                [_deviceArray removeAllObjects];
                _deviceArray = array;
                [self getDeviceInfoList];
                appDelegate.deviceArray = array;
                [self.tableView reloadData];
            });
        }
    });
}

/*Refresh device list.*/
- (void)getDeviceInfoList
{
    int i;
    @synchronized(_statusArray)
    {
        for (i=0; i<_statusArray.count; i++)
        {
            BLAirQualityInfo *stInfo = [_statusArray objectAtIndex:i];
            if (!stInfo.isRefresh)
            {
                NSString *state = @"";
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:[NSNumber numberWithInt:16] forKey:@"api_id"];
                [dic setObject:@"device_state" forKey:@"command"];
                [dic setObject:stInfo.mac forKey:@"mac"];
                NSData *requestData = [dic JSONData];
                NSData *responseData = [_networkAPI requestDispatch:requestData];
                if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
                {
                    state = [[responseData objectFromJSONData] objectForKey:@"status"];
                }
                //设备不在线
                if ([state isEqualToString:@"OFFLINE"] || [state isEqualToString:@"NOT_INIT"])
                {
                    stInfo.hour = 0;
                    stInfo.minute = 0;
                    [stInfo setIsRefresh:NO];
                    [stInfo setSleepState:0];
                    [stInfo setSwitchState:0];
                    [_statusArray replaceObjectAtIndex:i withObject:stInfo];
                    [_tableView reloadData];
                }
                else if ([state isEqualToString:@"LOCAL"] || [state isEqualToString:@"REMOTE"])
                {
                    dispatch_async(networkQueue, ^{
                        //数据透传
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                        [dic setObject:[NSNumber numberWithInt:9000] forKey:@"api_id"];
                        [dic setObject:@"passthrough" forKey:@"command"];
                        [dic setObject:stInfo.mac forKey:@"mac"];
                        [dic setObject:@"bytes" forKey:@"format"];
                        
                        NSMutableArray *dataArray = [[NSMutableArray alloc ]init];
                        for (int i = 0; i <= 24; i++)
                        {
                            if( i == 0)
                                [dataArray addObject:[NSNumber numberWithInt:0xfe]];
                            else if( i == 1)
                                [dataArray addObject:[NSNumber numberWithInt:0x45]];
                            else if( i == 23)
                                [dataArray addObject:[NSNumber numberWithInt:0x00]];
                            else if( i == 24)
                                [dataArray addObject:[NSNumber numberWithInt:0xaa]];
                            else
                                [dataArray addObject:[NSNumber numberWithInt:0x00]];
                        }
                        [dic setObject:dataArray forKey:@"data"];
                        
                        NSData *sendData = [dic JSONData];
                        NSData *response = [_networkAPI requestDispatch:sendData];
                        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
                        if (code == 0)
                        {
                            NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
                            
                            //判断数据是否相等
                            if(stInfo.sleepState != [array[7] intValue] || stInfo.switchState != [array[4] intValue] || stInfo.hour != [array[9] intValue] || stInfo.minute != [array[10] intValue])
                            {
                                stInfo.hour = [array[9] intValue];
                                stInfo.minute = [array[10] intValue];
                                stInfo.sleepState = [array[7] intValue];
                                stInfo.isRefresh = YES;
                                stInfo.switchState = [array[4] intValue];
                                [_statusArray replaceObjectAtIndex:i withObject:stInfo];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [_tableView reloadData];
                                });
                            }
                        }
                    });
                }
            }
        }
    }
}

- (void)getNewModuleInfo:(BLDeviceInfo *)info
{
    /*Create default icon*/
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"SharedData/DeviceIcon/%@.png", info.mac]];
    NSString *path;
    UIImage *image;
    BLModuleInfomation *moduleInfo;
    long infoID;
    
    if (![info.type isEqualToString:[NSString stringWithFormat:@"%d",BROADLINK_BeiAngAir]])
        return;
    
    path = [[NSBundle mainBundle] pathForResource:@"device_icon@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    
    infoID = [sqlite getMaxInfoID] + 1;
    moduleInfo = [[BLModuleInfomation alloc] init];
    [moduleInfo setInfo:info];
    [moduleInfo setInfoID:infoID];
    [moduleInfo setIsNew:1];
    [sqlite insertOrUpdateModuleInfo:moduleInfo];
}

- (void)addDeviceInfo:(BLDeviceInfo *)info
{
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [dic setObject:[NSNumber numberWithInt:12] forKey:@"api_id"];
        [dic setObject:@"device_add" forKey:@"command"];
        [dic setObject:info.mac forKey:@"mac"];
        [dic setObject:info.name forKey:@"name"];
        [dic setObject:info.type forKey:@"type"];
        [dic setObject:[NSNumber numberWithInt:info.lock] forKey:@"lock"];
        [dic setObject:[NSNumber numberWithUnsignedInt:info.password] forKey:@"password"];
        [dic setObject:[NSNumber numberWithInt:info.terminal_id] forKey:@"id"];
        [dic setObject:[NSNumber numberWithInt:info.sub_device] forKey:@"subdevice"];
        [dic setObject:info.key forKey:@"key"];
        
        NSData *sendData = [dic JSONData];
        NSLog(@"%@", sendData);
        /*Send data*/
        NSData *response = [_networkAPI requestDispatch:sendData];
        if ([[[response objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            NSLog(@"Add device:%@ success", info.mac);
        }
    });
}

/*该方法仅为了解决UITableView多余的分割线*/
- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{    
    // 创建一个bitmap的context    
    // 并把它设置成为当前正在使用的context    
    UIGraphicsBeginImageContext(size);    
    // 绘制改变大小的图片    
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];    
    // 从当前context中创建一个改变大小后的图片    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
    // 使当前的context出堆栈    
    UIGraphicsEndImageContext();    
    // 返回新的改变大小后的图片    
    return scaledImage;    
}

#pragma mark -
#pragma mark - UITableView Datasource Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        dispatch_async(networkQueue, ^{
            BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            
            [dic setObject:[NSNumber numberWithInt:14] forKey:@"api_id"];
            [dic setObject:@"device_delete" forKey:@"command"];
            [dic setObject:info.mac forKey:@"mac"];
            NSData *sendData = [dic JSONData];
            /*Send data.*/
            NSData *response = [_networkAPI requestDispatch:sendData];
            int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
            if (code == 0)
            {
                [_deviceArray removeObjectAtIndex:indexPath.row];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView reloadData];
                });
            }
        });
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TclAirDeviceListCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell.contentView setFrame:CGRectMake(0.0f, 0.0f, cell.frame.size.width, 94.0f)];
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        for (UIView *view in [cell.contentView subviews])
        {
            [view removeFromSuperview];
        }
        for (UIView *view in [cell.imageView subviews])
        {
            [view removeFromSuperview];
        }
        [cell.accessoryView removeFromSuperview];
    }
    //设备信息
    BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
    @autoreleasepool {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"SharedData/DeviceIcon/%@.png", info.mac]];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
//    [cell.imageView setImage:image];
        CGRect viewFrame = cell.imageView.frame;
        viewFrame.origin.x = 10.0f;
        viewFrame.origin.y = (94.0f - 62.5) * 0.5f;
        viewFrame.size = CGSizeMake(62.5, 62.5);
        UIButton *button = [[UIButton alloc] initWithFrame:viewFrame];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTag:indexPath.row];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:button.frame.size.width / 2.f];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button];
    }
//    path = [[NSBundle mainBundle] pathForResource:@"right@2x" ofType:@"png"];
    UIImage *image = [UIImage imageNamed:@"right@2x.png"];
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = cell.contentView.frame.size.width - 36.f;
    viewFrame.origin.y = (cell.contentView.frame.size.height - 36.f) * 0.5f;
    viewFrame.size = CGSizeMake(36.f, 36.f);
    UIImageView *infoImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [infoImageView setBackgroundColor:[UIColor clearColor]];
    [infoImageView setImage:image];
    [cell.contentView addSubview:infoImageView];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = 72.5 + 10.0f;
    viewFrame.origin.y = 20.0f;
    viewFrame.size = CGSizeMake(220, 22.0f);
    UILabel *textLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setText:info.name];
    [textLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [textLabel setTextColor:RGB(0x33, 0x33, 0x33)];
    [cell.contentView addSubview:textLabel];
    //设备的信息
    @synchronized(_statusArray)
    {
    for (int i=0; i<_statusArray.count; i++)
    {
        BLAirQualityInfo *stInfo = [_statusArray objectAtIndex:i];
        if ([stInfo.mac isEqualToString:info.mac] && stInfo.isRefresh)
        {
            viewFrame.origin.y += viewFrame.size.height + 1.0f;
            viewFrame.size.height = 15.f;
            UILabel *label = [[UILabel alloc] initWithFrame:viewFrame];
            viewFrame.origin.y += viewFrame.size.height + 1.0f;
            UILabel *labelRunTime = [[UILabel alloc] initWithFrame:viewFrame];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setLineBreakMode:NSLineBreakByWordWrapping];
            [label setFont:[UIFont systemFontOfSize:11.0f]];
            [labelRunTime setBackgroundColor:[UIColor clearColor]];
            [labelRunTime setLineBreakMode:NSLineBreakByWordWrapping];
            [labelRunTime setFont:[UIFont systemFontOfSize:11.0f]];
            if (stInfo.switchState == 1)
            {
                if(stInfo.sleepState == 1)
                    [label setText:@"睡眠开"];
                else
                    [label setText:@"睡眠关"];
            }
            else
            {
                [label setText:@"设备已关闭"];
            }
            [labelRunTime setText:[NSString stringWithFormat:@"设备已运行%d小时%d分钟 ",stInfo.hour,stInfo.minute]];
            viewFrame = [label textRectForBounds:viewFrame limitedToNumberOfLines:1];
            viewFrame.origin.x = textLabel.frame.origin.x;
            viewFrame.origin.y = label.frame.origin.y;
            viewFrame.size.width = 220;
            [label setFrame:viewFrame];
            
            viewFrame = [labelRunTime textRectForBounds:viewFrame limitedToNumberOfLines:1];
            viewFrame.origin.x = textLabel.frame.origin.x;
            viewFrame.origin.y = labelRunTime.frame.origin.y;
            viewFrame.size.width = 220;
            [labelRunTime setFrame:viewFrame];
            
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:labelRunTime];
        }
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BLDeviceInfo *info = [appDelegate.deviceArray objectAtIndex:indexPath.row];
    
    dispatch_async(networkQueue, ^{
        [MMProgressHUD showWithTitle:@"Network" status:@"Getting"];
        //数据透传
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:9000] forKey:@"api_id"];
        [dic setObject:@"passthrough" forKey:@"command"];
        [dic setObject:info.mac forKey:@"mac"];
        [dic setObject:@"bytes" forKey:@"format"];
        
        NSMutableArray *dataArray = [[NSMutableArray alloc ]init];
        for (int i = 0; i <= 24; i++)
        {
            if( i == 0)
                [dataArray addObject:[NSNumber numberWithInt:0xfe]];
            else if( i == 1)
                [dataArray addObject:[NSNumber numberWithInt:0x45]];
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
        NSData *response = [_networkAPI requestDispatch:sendData];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        if (code == 0)
        {
            [MMProgressHUD dismiss];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
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
                appDelegate.currentAirInfo = recvInfo;
                appDelegate.deviceInfo = info;
                //详细界面
                BLAirQualityViewController *airQualityViewController = [[BLAirQualityViewController alloc] init];
                [self.navigationController pushViewController:airQualityViewController animated:YES];
            });
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [MMProgressHUD dismiss];
                [self.view makeToast:[[response objectFromJSONData] objectForKey:@"msg"] duration:0.8f position:@"bottom"];
            });
        }
    });
}


- (void)editButtonClicked:(UIButton *)button
{
    //设备编辑页面
    BLDeviceInfo *info = [appDelegate.deviceArray objectAtIndex:button.tag];
    appDelegate.deviceInfo = info;
    BLDeviceInfoEditViewController *vc = [[BLDeviceInfoEditViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark -  
#pragma mark Data Source Loading / Reloading Methods  
//开始重新加载时调用的方法  
- (void)reloadTableViewDataSource{  
    _reloading = YES; 
    
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
}  

//完成加载时调用的方法  
- (void)doneLoadingTableViewData{  
    NSLog(@"doneLoadingTableViewData");  
    
    _reloading = NO;  
    [_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];        
}  

#pragma mark -  
#pragma mark Background operation  
//这个方法运行于子线程中，完成获取刷新数据的操作  
-(void)doInBackground  
{  
    NSLog(@"doInBackground");     
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshDeviceList];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doneLoadingTableViewData];
        });
    });  
}

#pragma mark -  
#pragma mark EGORefreshTableHeaderDelegate Methods  
//下拉被触发调用的委托方法  
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view  
{  
    [self reloadTableViewDataSource];  
}  

//返回当前是刷新还是无刷新状态  
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view  
{  
    return _reloading;  
}  

//返回刷新时间的回调方法  
-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view  
{  
    return [NSDate date];  
}  

#pragma mark -   
#pragma mark UIScrollViewDelegate Methods  
//滚动控件的委托方法  
-(void)scrollViewDidScroll:(UIScrollView *)scrollView  
{  
    [_refreshTableView egoRefreshScrollViewDidScroll:scrollView];  
}  

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate  
{  
    [_refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];  
} 

@end
