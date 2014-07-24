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
#import "BLDeviceControlViewController.h"
#import "JSONKit.h"
#import "BLDeviceEditViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface BLDeviceListViewController ()

@property (nonatomic, assign) dispatch_queue_t networkQueue;
@property (nonatomic, strong) BLNetwork *networkAPI;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *devices;

@end

@implementation BLDeviceListViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {
		self.title = NSLocalizedString(@"DeviceListViewControllerTitle", nil);
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBarHidden = NO;
	
	self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100.0f)];
	[self.refreshControl addTarget:self action:@selector(doInBackground) forControlEvents:UIControlEventValueChanged];
	[self.tableView.tableHeaderView addSubview:self.refreshControl];
	
	//背景颜色
    [self.view setBackgroundColor:RGB(246.0f, 246.0f, 246.0f)];
    
    //底部的添加设备
	CGRect viewFrame = CGRectZero;
    UIButton *btnAddDevice = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49-43, self.view.frame.size.width, 43)];
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
	
	_networkAPI = [[BLNetwork alloc] init];
	_networkQueue = dispatch_queue_create("BLDeviceListViewControllerNetworkQueue", DISPATCH_QUEUE_SERIAL);
	_devices = [[BLDevice allDevices] mutableCopy];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doInBackground) name:BEIANG_NOTIFICATION_IDENTIFIER_ADDED_DEVICE object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self doInBackground];
}

- (void)dealloc
{
	dispatch_release(_networkQueue);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:BEIANG_NOTIFICATION_IDENTIFIER_ADDED_DEVICE object:nil];
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
		NSLog(@"objectFromJSONData: %@", [response objectFromJSONData]);
        if (code == 0) {
            NSArray *list = [[response objectFromJSONData] objectForKey:@"list"];
			NSLog(@"prob count: %d", list.count);
            for (int i = 0; i < list.count; i++) {
                BLDevice *device = [[BLDevice alloc] init];
                NSDictionary *item = [list objectAtIndex:i];
                [device setMac:[item objectForKey:@"mac"]];
                [device setType:[item objectForKey:@"type"]];
                [device setName:[item objectForKey:@"name"]];
                [device setLock:[[item objectForKey:@"lock"] intValue]];
                [device setPassword:[[item objectForKey:@"password"] unsignedIntValue]];
                [device setTerminal_id:[[item objectForKey:@"id"] intValue]];
                [device setSub_device:[[item objectForKey:@"subdevice"] intValue]];
                [device setKey:[item objectForKey:@"key"]];
				
				if (![device hadPersistenced]) {
					if ([device isBeiAngAirDevice]) {
						[device persistence];
						NSLog(@"persistence");
						[_devices addObject:device];
						
					}
				}
				[self addDeviceInfo:device];
			}

            dispatch_async(dispatch_get_main_queue(), ^{
				[self.tableView reloadData];
				[self performSelector:@selector(getDeviceInfoList) withObject:nil afterDelay:2.0];
            });
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.tableView reloadData];
				[self getDeviceInfoList];
			});
		}
    });
}

/*Refresh device list.*/
- (void)getDeviceInfoList
{
	@synchronized(_devices) {
		for (int i = 0; i < _devices.count; i++) {
			BLDevice *device = _devices[i];
			NSDictionary *dictionary = [NSDictionary dictionaryDeviceStateWithMAC:device.mac];
			NSData *requestData = [dictionary JSONData];
			NSData *responseData = [_networkAPI requestDispatch:requestData];
			NSString *state = @"";
			NSLog(@"DeviceStateWithMAC: %@", [responseData objectFromJSONData]);
			if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0) {
				state = [[responseData objectFromJSONData] objectForKey:@"status"];
			}
			
			if ([state isEqualToString:@"LOCAL"] || [state isEqualToString:@"REMOTE"]) {
				dispatch_async(_networkQueue, ^{
					//数据透传
					NSDictionary *dictionary = [NSDictionary dictionaryPassthroughWithMAC:device.mac];
					NSData *sendData = [dictionary JSONData];
					NSData *response = [_networkAPI requestDispatch:sendData];
					int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
					if (code == 0) {
						NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
						device.hour = [array[9] intValue];
						device.minute = [array[10] intValue];
						device.sleepState = [array[7] intValue];
						device.isRefresh = YES;
						device.switchState = [array[4] intValue];
						dispatch_async(dispatch_get_main_queue(), ^{
							[self.tableView reloadData];
						});
					}
				});
			}
		}
	}
}

- (void)addDeviceInfo:(BLDevice *)info
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 1;
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
            BLDevice *device = _devices[indexPath.row];
			NSDictionary *dictionary = [NSDictionary dictionaryDeviceDeleteWithMAC:device.mac];
            NSData *sendData = [dictionary JSONData];
            NSData *response = [_networkAPI requestDispatch:sendData];
            int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
            if (code == 0) {
				[_devices removeObject:device];
				[device remove];
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
	BLDevice *device = _devices[indexPath.row];
	cell.imageView.image = [device avatar];
	cell.imageView.userInteractionEnabled = YES;
	cell.imageView.tag = indexPath.row;
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editDeviceAvatar:)];
	[cell.imageView addGestureRecognizer:tapGestureRecognizer];
	cell.textLabel.text = device.name;

	if (device.isRefresh) {
		NSString *status = NSLocalizedString(@"设备已关闭", nil);
		if (device.switchState == 1) {
			status = NSLocalizedString(@"设备正在运行", nil);
		}
		
		NSString *statusAndrunTime = [NSString stringWithFormat:@"%@\n已运行%d小时%d分钟", status, device.hour, device.minute];
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:statusAndrunTime];
		if (device.hour >= 50) {
			NSAttributedString *subString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@" 请清洗", nil) attributes:@{NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName : [UIFont systemFontOfSize:13]}];
			[attributedString appendAttributedString:subString];
		}
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.attributedText = attributedString;
	}
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLDevice *device = [_devices objectAtIndex:indexPath.row];
	
//	BLDeviceControlViewController *controller = [[BLDeviceControlViewController alloc] init];
//	controller.device = device;
//	[self.navigationController pushViewController:controller animated:YES];
//	return;
	
	[self displayHUD:NSLocalizedString(@"加载中...", nil)];
    dispatch_async(_networkQueue, ^{
        //数据透传
		NSDictionary *dictionary = [NSDictionary dictionaryPassthroughWithMAC:device.mac];
        NSData *sendData = [dictionary JSONData];
        NSData *response = [_networkAPI requestDispatch:sendData];
        int code = [[[response objectFromJSONData] objectForKey:@"code"] intValue];
        if (code == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
				[self hideHUD:YES];
                NSArray *array = [[response objectFromJSONData] objectForKey:@"data"];
                BeiAngReceivedData *receivedData = [[BeiAngReceivedData alloc] initWithData:array];
				NSLog(@"BeiAngReceivedDataInfo: %@", receivedData);
                BLDeviceControlViewController *controller = [[BLDeviceControlViewController alloc] init];
				controller.receivedData = receivedData;
				controller.device = device;
                [self.navigationController pushViewController:controller animated:YES];
            });
        } else {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self hideHUD:YES];
				[self displayHUDTitle:NSLocalizedString(@"设备不可用", nil) message:nil duration:2];
			});
        }
    });
}

- (void)editDeviceAvatar:(UITapGestureRecognizer *)recognizer
{
    BLDevice *device = [_devices objectAtIndex:recognizer.view.tag];
    BLDeviceEditViewController *controller = [[BLDeviceEditViewController alloc] init];
	controller.device = device;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark Background operation  
//这个方法运行于子线程中，完成获取刷新数据的操作
-(void)doInBackground  
{  
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshDeviceList];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.refreshControl endRefreshing];
				[self.tableView reloadData];
			});
        });
    });  
}

@end
