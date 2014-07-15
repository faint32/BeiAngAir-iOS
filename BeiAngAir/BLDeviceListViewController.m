//
//  BLDeviceListViewController.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceListViewController.h"
#import "GlobalDefine.h"
#import "BLSmartConfigViewController.h"
#import "BLNetwork.h"
#import "EGORefreshTableHeaderView.h"
#import "UILabel+Attribute.h"
#import "Toast+UIView.h"
#import "BLAirQualityViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "BLDeviceInfoEditViewController.h"
#import "MMProgressHUD.h"
#import "UIViewController+MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import "BLCustomHUD+UIWindow.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "UIImage+Retina4.h"

@interface BLDeviceListViewController () <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableView;
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, assign) dispatch_queue_t networkQueue;
@property (nonatomic, strong) BLNetwork *networkAPI;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *devices;

@end

@implementation BLDeviceListViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"DeviceListViewControllerTitle", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBarHidden = NO;
	
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleFade];
	//背景颜色
    [self.view setBackgroundColor:RGB(246.0f, 246.0f, 246.0f)];
    
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = 0.0f;
    viewFrame.origin.y = 0.0f;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = 44.0f + ((IsiOS7Later) ? 20.0f : 0.0f);
    UIView *headerView = [[UIView alloc] initWithFrame:viewFrame];
    [headerView setBackgroundColor:[UIColor whiteColor]];
//    [self.view addSubview:headerView];//TODO: remove title view
    
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
//    [headerView addSubview:titleLabel];//TODO: title color
    
    //底部的添加设备
    UIButton *btnAddDevice = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-43, self.view.frame.size.width, 43)];
    //button(ALL,Senior,Ordinary)显示数据
    //背景颜色
    btnAddDevice.backgroundColor = [UIColor whiteColor];
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
	_tableView = [[UITableView alloc] initWithFrame:viewFrame style:UITableViewStyleGrouped];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setShowsHorizontalScrollIndicator:NO];
    [_tableView.layer setBorderColor:RGBA(0x00, 0x00, 0x00, 0.3f).CGColor];
    [_tableView.layer setBorderWidth:0.5f];
    [self.view addSubview:_tableView];

	_refreshTableView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, _tableView.frame.size.width, _tableView.bounds.size.height)];
	_refreshTableView.delegate = self;
	[_tableView addSubview:_refreshTableView];
	
	_networkAPI = [[BLNetwork alloc] init];
	_networkQueue = dispatch_queue_create("BLDeviceListViewControllerNetworkQueue", DISPATCH_QUEUE_SERIAL);
	_devices = [BLDeviceInfo allDevices];
	[self refreshDeviceList];
}

- (void)dealloc
{
	dispatch_release(_networkQueue);
}

- (void)addNewDevice
{
	BLSmartConfigViewController *controller = [[BLSmartConfigViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)refreshDeviceList
{
    dispatch_async(_networkQueue, ^{
		NSDictionary *dictionary = [NSDictionary dictionaryProbeList];
        NSData *sendData = [dictionary JSONData];
        NSData *response = [_networkAPI requestDispatch:sendData];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        if (code == 0) {
            NSArray *list = [[response objectFromJSONData] objectForKey:@"list"];
			NSLog(@"prob count: %d", list.count);
            for (int i = 0; i < list.count; i++) {
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
				NSLog(@"info: %@", info);
				
				if (![info hadPersistenced]) {
					if ([info isBeiAngAirDevice]) {
						[info persistence];
						[self addDeviceInfo:info];
					}
				}
			}

            dispatch_async(dispatch_get_main_queue(), ^{
                _devices = [BLDeviceInfo allDevices];
                [self getDeviceInfoList];
                [self.tableView reloadData];
            });
        }
    });
	
	//TODO: will crash
	[self performSelector:@selector(refreshDeviceList) withObject:nil afterDelay:5.0];
}

/*Refresh device list.*/
- (void)getDeviceInfoList
{
	@synchronized(_devices) {
		for (int i = 0; i < _devices.count; i++) {
			BLDeviceInfo *device = _devices[i];
			BLAirQualityInfo *airQualityInfo = device.airQualityInfo;
			
			NSDictionary *dictionary = [NSDictionary dictionaryDeviceStateWithMAC:device.mac];
			NSData *requestData = [dictionary JSONData];
			NSData *responseData = [_networkAPI requestDispatch:requestData];
			NSString *state = @"";
			if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0) {
				state = [[responseData objectFromJSONData] objectForKey:@"status"];
			}
			
			if ([state isEqualToString:@"OFFLINE"] || [state isEqualToString:@"NOT_INIT"]) {
				airQualityInfo.hour = 0;
				airQualityInfo.minute = 0;
				airQualityInfo.isRefresh = NO;
				airQualityInfo.sleepState = 0;
				airQualityInfo.switchState = 0;
				[_tableView reloadData];
			} else if ([state isEqualToString:@"LOCAL"] || [state isEqualToString:@"REMOTE"]) {
				dispatch_async(_networkQueue, ^{
					//数据透传
					NSDictionary *dictionary = [NSDictionary dictionaryPassthroughWithMAC:device.mac];
					NSData *sendData = [dictionary JSONData];
					NSData *response = [_networkAPI requestDispatch:sendData];
					int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
					if (code == 0) {
						NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
						airQualityInfo.hour = [array[9] intValue];
						airQualityInfo.minute = [array[10] intValue];
						airQualityInfo.sleepState = [array[7] intValue];
						airQualityInfo.isRefresh = YES;
						airQualityInfo.switchState = [array[4] intValue];
						dispatch_async(dispatch_get_main_queue(), ^{
							[_tableView reloadData];
						});
					}
				});
			}
		}
	}
}

- (void)addDeviceInfo:(BLDeviceInfo *)info
{
    dispatch_async(_networkQueue, ^{
		NSDictionary *dictionary = [NSDictionary dictionaryDeviceAddWithMAC:info.mac name:info.name type:info.type lock:@(info.lock) password:@(info.password) terminalID:@(info.terminal_id) subDevice:@(info.sub_device) key:info.key];
        NSData *sendData = [dictionary JSONData];
        NSData *response = [_networkAPI requestDispatch:sendData];
        if ([[[response objectFromJSONData] objectForKey:@"code"] intValue] == 0) {
            NSLog(@"Add device:%@ success", info.mac);
        }
    });
}

#pragma mark - UITableView Datasource Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _devices.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dispatch_async(_networkQueue, ^{
            BLDeviceInfo *device = _devices[indexPath.row];
			NSDictionary *dictionary = [NSDictionary dictionaryDeviceDeleteWithMAC:device.mac];
            NSData *sendData = [dictionary JSONData];
            NSData *response = [_networkAPI requestDispatch:sendData];
            int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
            if (code == 0) {
				[device remove];
				_devices = [BLDeviceInfo allDevices];
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
	NSLog(@"devices count: %d", _devices.count);
	NSLog(@"devices : %@", _devices);
	BLDeviceInfo *deviceInfo = _devices[indexPath.row];
	cell.imageView.image = [deviceInfo avatar];
	cell.imageView.userInteractionEnabled = YES;
	cell.imageView.tag = indexPath.row;
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDeviceAvatar:)];
	[cell.imageView addGestureRecognizer:tapGestureRecognizer];
	cell.textLabel.text = deviceInfo.name;

	BLAirQualityInfo *airQualityInfo = deviceInfo.airQualityInfo;
	if (airQualityInfo.isRefresh) {
		NSString *status = NSLocalizedString(@"设备已关闭", nil);
		if (airQualityInfo.switchState == 1) {
			status = airQualityInfo.sleepState == 1 ? NSLocalizedString(@"睡眠开", nil) : NSLocalizedString(@"睡眠关", nil);
		}
		
		NSString *statusAndrunTime = [NSString stringWithFormat:@"%@\n设备已运行%d小时%d分钟", status, airQualityInfo.hour, airQualityInfo.minute];
		NSMutableAttributedString *attributedString;
		if (airQualityInfo.hour >= 50) {
			NSDictionary *wordToColorMapping = @{statusAndrunTime : [UIColor blackColor], @"请清洗!" : [UIColor redColor]};
			attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
			for (NSString *word in wordToColorMapping) {
				UIColor *color = [wordToColorMapping objectForKey:word];
				NSDictionary *attributes = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
				NSAttributedString *subString = [[NSAttributedString alloc] initWithString:word attributes:attributes];
				[attributedString appendAttributedString:subString];
			}
		} else {
			attributedString = [[NSMutableAttributedString alloc] initWithString:statusAndrunTime];
		}
		cell.detailTextLabel.attributedText = attributedString;
	}
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLDeviceInfo *info = [_devices objectAtIndex:indexPath.row];
    dispatch_async(_networkQueue, ^{
        [MMProgressHUD showWithTitle:@"Network" status:@"Getting"];
        //数据透传
		NSDictionary *dictionary = [NSDictionary dictionaryPassthroughWithMAC:info.mac];
        NSData *sendData = [dictionary JSONData];
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
    BLDeviceInfo *info = [_devices objectAtIndex:recognizer.view.tag];
    BLDeviceInfoEditViewController *vc = [[BLDeviceInfoEditViewController alloc] init];
	vc.deviceInfo = info;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark Data Source Loading / Reloading Methods  

- (void)reloadTableViewDataSource
{
    _reloading = YES;
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
}  


- (void)doneLoadingTableViewData
{
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
