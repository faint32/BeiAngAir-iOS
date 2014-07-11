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
#import "UILabel+Attribute.h"
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
#import "UIImage+Retina4.h"

@interface BLDeviceListViewController () <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    BLAppDelegate *appDelegate;
    BLFMDBSqlite *sqlite;
    dispatch_queue_t networkQueue;
    EGORefreshTableHeaderView *_refreshTableView;  
    BOOL _reloading;
}

@property (nonatomic, strong) BLNetwork *networkAPI;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) NSMutableArray *statusArray;
@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation BLDeviceListViewController

- (void)dealloc
{
    [super dealloc];
    dispatch_release(networkQueue);
}

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
    _networkAPI = [[BLNetwork alloc] init];
//    _beiAngAirNetwork = [BeiAngNetworkUnit sharedNetworkAPI];
    sqlite = [BLFMDBSqlite sharedFMDBSqlite];
    networkQueue = dispatch_queue_create("BLDeviceListViewControllerNetworkQueue", DISPATCH_QUEUE_SERIAL);
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
    _deviceArray = [[NSMutableArray alloc] init];
    NSMutableArray *muTableArray = [[NSMutableArray alloc] initWithArray:[sqlite getAllModuleInfo]];
    for (BLModuleInfomation *tmp in muTableArray) {
        BLDeviceInfo *deviceInfo = tmp.info;
		NSLog(@"deviceInfo: %@", deviceInfo);
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
    UIImage *image = [UIImage imageNamed:@"enter"];
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
                    if([infoTmp.mac isEqualToString:info.mac])
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
	NSString *imagePath = [NSString deviceAvatarPathWithMAC:info.mac];
    UIImage *image;
    BLModuleInfomation *moduleInfo;
    long infoID;
    
    if (![info.type isEqualToString:[NSString stringWithFormat:@"%d",BROADLINK_BeiAngAir]])
        return;
	
    image = [UIImage imageNamed:@"device_icon"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
		cell.backgroundColor = [UIColor whiteColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
    //设备信息
    BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
	NSString *path = [NSString deviceAvatarPathWithMAC:info.mac];
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	cell.imageView.image = image;
	cell.imageView.userInteractionEnabled = YES;
	cell.imageView.tag = indexPath.row;
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDeviceAvatar:)];
	[cell.imageView addGestureRecognizer:tapGestureRecognizer];
	
	cell.textLabel.text = info.name;
    //设备的信息
    @synchronized(_statusArray)
    {
		for (int i=0; i<_statusArray.count; i++) {
			BLAirQualityInfo *stInfo = [_statusArray objectAtIndex:i];
			if ([stInfo.mac isEqualToString:info.mac] && stInfo.isRefresh) {
				NSString *status = NSLocalizedString(@"设备已关闭", nil);
				if (stInfo.switchState == 1) {
					status = stInfo.sleepState == 1 ? NSLocalizedString(@"睡眠开", nil) : NSLocalizedString(@"睡眠关", nil);
				}
				
				NSString *runTime = [NSString stringWithFormat:@"设备已运行%d小时%d分钟", stInfo.hour, stInfo.minute];
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", status, runTime];
			}
		}
    }
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
    
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
        if (code == 0) {
            [MMProgressHUD dismiss];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
                BeiAngReceivedDataInfo *recvInfo = [[BeiAngReceivedDataInfo alloc] initWithData:array];
                BLAirQualityViewController *airQualityViewController = [[BLAirQualityViewController alloc] init];
				airQualityViewController.currentAirInfo = recvInfo;
				airQualityViewController.deviceInfo = info;
                [self.navigationController pushViewController:airQualityViewController animated:YES];
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [MMProgressHUD dismiss];
                [self.view makeToast:[[response objectFromJSONData] objectForKey:@"msg"] duration:0.8f position:@"bottom"];
            });
        }
    });
}


- (void)editDeviceAvatar:(UITapGestureRecognizer *)recognizer
{
    BLDeviceInfo *info = [_deviceArray objectAtIndex:recognizer.view.tag];
    BLDeviceInfoEditViewController *vc = [[BLDeviceInfoEditViewController alloc] init];
	vc.deviceInfo = info;
    [self presentViewController:vc animated:YES completion:nil];
}

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
