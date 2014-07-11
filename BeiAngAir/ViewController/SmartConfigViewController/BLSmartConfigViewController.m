//
//  BLSmartConfigViewController.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLSmartConfigViewController.h"
#import "GlobalDefine.h"
#import "BLNetwork.h"
#import "JSONKit.h"
#import "Toast+UIView.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface BLSmartConfigViewController () <UITextFieldDelegate,UIAlertViewDelegate>
{
    BLNetwork *configAPI;
}

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITextField *ssidTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIView *waitingView;
@property (nonatomic, strong) UIButton *configButton;

@end

@implementation BLSmartConfigViewController

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
	
    configAPI = [[BLNetwork alloc] init];
    
    [self.view setBackgroundColor:RGB(246.0f, 246.0f, 246.0f)];
    
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = 0.0f;
    viewFrame.origin.y = 0.0f;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = 44.0f + ((IsiOS7Later) ? 20.0f : 0.0f);
    _headerView = [[UIView alloc] initWithFrame:viewFrame];
    [_headerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_headerView];
    
    viewFrame = _headerView.frame;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [titleLabel setTextColor:RGB(0x13, 0xb3, 0x5c)];
    [titleLabel setText:NSLocalizedString(@"SmartConfigViewControllerTitle", nil)];
    viewFrame = [titleLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.x = (_headerView.frame.size.width - viewFrame.size.width) * 0.5f;
    viewFrame.origin.y = (44.0f - viewFrame.size.height) * 0.5f + ((IsiOS7Later) ? 20.0f : 0.0f);
    [titleLabel setFrame:viewFrame];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_headerView addSubview:titleLabel];
	
	
	//TODO: 
//	
//	
//	
//    UIImage *image = [UIImage imageNamed:@"left"];
//    viewFrame = CGRectZero;
//    viewFrame.origin.x = 10.0f;
//    viewFrame.size = image.size;
//    viewFrame.origin.y = ((IsiOS7Later) ? 20.0f : 0.0f) + (44.0f - image.size.height) * 0.5f;
//    UIButton *backButton = [[UIButton alloc] initWithFrame:viewFrame];
//    [backButton setBackgroundColor:[UIColor clearColor]];
//    [backButton setImage:image forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [_headerView addSubview:backButton];
	
    viewFrame = _headerView.frame;
    viewFrame.origin.y += viewFrame.size.height + 50.0f;
    viewFrame.origin.x = 30.0f;
    UILabel *addLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [addLabel setBackgroundColor:[UIColor clearColor]];
    [addLabel setTextColor:[UIColor grayColor]];
    [addLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [addLabel setTextAlignment:NSTextAlignmentLeft];
    [addLabel setText:NSLocalizedString(@"SmartConfigViewControllerAddLabelText", nil)];
    [self.view addSubview:addLabel];

    viewFrame = addLabel.frame;
    viewFrame.origin.y += viewFrame.size.height;
    viewFrame.size = CGSizeMake(80.0f, 32.0f);
    UILabel *ssidLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [ssidLabel setBackgroundColor:[UIColor clearColor]];
    [ssidLabel setTextColor:[UIColor blackColor]];
    [ssidLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [ssidLabel setText:NSLocalizedString(@"SmartConfigViewControllerSSIDLabelText", nil)];
    [self.view addSubview:ssidLabel];
    
    //ssid
    viewFrame = ssidLabel.frame;
    viewFrame.origin.x += viewFrame.size.width + 5.0f;
    viewFrame.size.width = self.view.frame.size.width - 30.0f - viewFrame.origin.x;
    _ssidTextField = [[UITextField alloc] initWithFrame:viewFrame];
    [_ssidTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_ssidTextField setReturnKeyType:UIReturnKeyNext];
    [_ssidTextField setTextColor:RGB(0x13, 0xb3, 0x5c)];
    [_ssidTextField setFont:[UIFont systemFontOfSize:17.0f]];
    [_ssidTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_ssidTextField setDelegate:self];
    //passwordText背景颜色
    UIImage *image = [UIImage imageNamed:@"input_squre"];
    _ssidTextField.background = image;
    [_ssidTextField setText:[self getCurrentWiFiSSID]];
    [self.view addSubview:_ssidTextField];
    
    viewFrame = ssidLabel.frame;
    viewFrame.origin.y += viewFrame.size.height + 5.0f;
    viewFrame.size = CGSizeMake(80.0f, 32.0f);
    UILabel *PWDLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [PWDLabel setBackgroundColor:[UIColor clearColor]];
    [PWDLabel setTextColor:[UIColor blackColor]];
    [PWDLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [PWDLabel setText:NSLocalizedString(@"SmartConfigViewControllerPWDLabelText", nil)];
    [self.view addSubview:PWDLabel];
    
    viewFrame = PWDLabel.frame;
    viewFrame.origin.x += viewFrame.size.width + 5.0f;
    viewFrame.size.width = self.view.frame.size.width - 30.0f - viewFrame.origin.x;
    _passwordTextField = [[UITextField alloc] initWithFrame:viewFrame];
    [_passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_passwordTextField setReturnKeyType:UIReturnKeyGo];
    [_passwordTextField setTextColor:RGB(0x13, 0xb3, 0x5c)];
    [_passwordTextField setFont:[UIFont systemFontOfSize:17.0f]];
    [_passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_passwordTextField setDelegate:self];
    [_passwordTextField setSecureTextEntry:YES];
    [_passwordTextField becomeFirstResponder];
    //passwordText背景颜色
    _passwordTextField.background=image;
	
	WifiInfo *wifiInfo = [WifiInfo wifiInfoWithSSID:_ssidTextField.text];
	_passwordTextField.text = wifiInfo.password;
    [self.view addSubview:_passwordTextField];
	
    image = [UIImage imageNamed:@"check_normal"];
    viewFrame = _passwordTextField.frame;
    viewFrame.origin.y += viewFrame.size.height + 15.0f;
    viewFrame.size.height = 25.0f;
    viewFrame.size.width = self.view.frame.size.width;
    UIButton *showPasswordButton = [[UIButton alloc] initWithFrame:viewFrame];
    [showPasswordButton setBackgroundColor:[UIColor clearColor]];
    [showPasswordButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, viewFrame.size.width - image.size.width)];
    [showPasswordButton setImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"check_press"];
    [showPasswordButton setImage:image forState:UIControlStateSelected];
    [showPasswordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [showPasswordButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, image.size.width, 0.0f, -image.size.width)];
    [showPasswordButton setTitle:NSLocalizedString(@"SmartConfigViewControllerShowPasswordText", nil) forState:UIControlStateNormal];
    [showPasswordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [showPasswordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [showPasswordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted | UIControlStateSelected];
    [showPasswordButton addTarget:self action:@selector(showPasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [showPasswordButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [showPasswordButton sizeToFit];
    viewFrame = showPasswordButton.frame;
    viewFrame.origin.x = (self.view.frame.size.width - viewFrame.size.width) * 0.5f;
    [showPasswordButton setFrame:viewFrame];
    [showPasswordButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, viewFrame.size.width - image.size.width)];
    [self.view addSubview:showPasswordButton];
	
    image = [UIImage imageNamed:@"btn_normal"];
    viewFrame.origin.x = (self.view.frame.size.width - image.size.width) * 0.5f;
    viewFrame.origin.y = self.view.frame.size.height - image.size.height - 20.0f;
    viewFrame.size = image.size;
    _configButton = [[UIButton alloc] initWithFrame:viewFrame];
    [_configButton setBackgroundColor:[UIColor clearColor]];
    [_configButton setBackgroundImage:image forState:UIControlStateNormal];
    [_configButton setTitle:NSLocalizedString(@"SmartConfigViewControllerConfigButtonText", nil) forState:UIControlStateNormal];
    [_configButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [_configButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_configButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_configButton addTarget:self action:@selector(configButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_configButton];
}

/*获取当前连接的wifi网络名称，如果未连接，则为nil*/
- (NSString *)getCurrentWiFiSSID
{
    CFArrayRef ifs = CNCopySupportedInterfaces();       //得到支持的网络接口 eg. "en0", "en1"
    
    if (ifs == NULL)
        return nil;
    
    CFDictionaryRef info = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(ifs, 0));
    
    CFRelease(ifs);
    
    if (info == NULL)
        return nil;
    
    NSDictionary *dic = (__bridge_transfer NSDictionary *)info;
    
    // If ssid is not exist.
    if ([dic isEqual:nil])
        return nil;
    NSString *ssid = [dic objectForKey:@"SSID"];
    return ssid;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)backButtonClicked
{
    //释放内存
    for (UIView *v in [_waitingView subviews])
        [v removeFromSuperview];
    [_waitingView removeFromSuperview];
    //取消配置
    [self cancelConfig];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configButtonClicked
{
	CGRect viewFrame = CGRectZero;
	viewFrame.origin.y = _headerView.frame.origin.y + _headerView.frame.size.height;
	viewFrame.size.width = self.view.frame.size.width;
	viewFrame.size.height = self.view.frame.size.height - viewFrame.origin.y;
	_waitingView = [[UIView alloc] initWithFrame:viewFrame];
	[_waitingView setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:_waitingView];
	viewFrame = _waitingView.frame;
	viewFrame.origin.x = 20.0f;
	viewFrame.size.width -= 40.0f;
	UILabel *configLabel = [[UILabel alloc] initWithFrame:viewFrame];
	[configLabel setBackgroundColor:[UIColor clearColor]];
	[configLabel setFont:[UIFont systemFontOfSize:15.0f]];
	[configLabel setTextColor:[UIColor grayColor]];
	[configLabel setText:NSLocalizedString(@"SmartConfigViewControllerConfigLabelText", nil)];
	[configLabel setNumberOfLines:3];
	viewFrame = [configLabel textRectForBounds:viewFrame limitedToNumberOfLines:3];
	viewFrame.origin.x = (_waitingView.frame.size.width - viewFrame.size.width) * 0.5f;
	viewFrame.origin.y = (_waitingView.frame.size.height - viewFrame.size.height) * 0.5f - 30.0f;
	[configLabel setFrame:viewFrame];
	[configLabel setTextAlignment:NSTextAlignmentCenter];
	[_waitingView addSubview:configLabel];
	UIImage *image = [UIImage imageNamed:@"wait"];
	viewFrame = configLabel.frame;
	viewFrame.origin.y += viewFrame.size.height + 10.0f;
	viewFrame.origin.x = (_waitingView.frame.size.width - image.size.width) * 0.5f;
	viewFrame.size = image.size;
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:viewFrame];
	[imageView setBackgroundColor:[UIColor clearColor]];
	[imageView setImage:image];
	CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];  
	rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];  
	rotationAnimation.duration = 2.0f;  
	rotationAnimation.cumulative = YES;  
	rotationAnimation.repeatCount = NSIntegerMax;  
	[imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
	[_waitingView addSubview:imageView];

	if (_ssidTextField.text.length && _passwordTextField.text.length) {
		WifiInfo *wifiInfo = [[WifiInfo alloc] init];
		wifiInfo.SSID = _ssidTextField.text;
		wifiInfo.password = _passwordTextField.text;
		[wifiInfo persistence];
		[self startConfig];
	}
}

/*Start config*/
- (void)startConfig
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:10000] forKey:@"api_id"];
        [dic setObject:@"easyconfig" forKey:@"command"];
        [dic setObject:_ssidTextField.text forKey:@"ssid"];
        [dic setObject:_passwordTextField.text forKey:@"password"];
//#warning If your device is v1, this field set 0.
        [dic setObject:[NSNumber numberWithInt:1] forKey:@"broadlinkv2"];
//#warning This filed is your route's gateway address.
        [dic setObject:@"" forKey:@"dst"];
        
        NSData *requestData = [dic JSONData];
        
        NSData *responseData = [configAPI requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
			
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[responseData objectFromJSONData] objectForKey:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        });
    });
}

#pragma marks -- UIAlertViewDelegate --
//根据被点击按钮的索引处理点击事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self backButtonClicked];
}

/*Cancel config*/
- (void)cancelConfig
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:10001] forKey:@"api_id"];
    [dic setObject:@"cancel_easyconfig" forKey:@"command"];
    
    NSData *requestData = [dic JSONData];
    
    NSData *responseData = [configAPI requestDispatch:requestData];
    NSLog(@"%@", [responseData objectFromJSONData]);
}

- (void)showPasswordButtonClicked:(UIButton *)button
{
    [button setSelected:![button isSelected]];
    [_passwordTextField setSecureTextEntry:![button isSelected]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self textFieldShouldReturn:nil];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_ssidTextField]) {
        [_passwordTextField resignFirstResponder];
        return NO;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.30f];
    self.view.frame = CGRectMake(0.0f, (IsiOS7Later) ? 0.0f : 20.0f, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    [self.view endEditing:YES];
    
    if ([textField isEqual:_passwordTextField])
    {
        [self configButtonClicked];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = self.view.frame.size.height - frame.origin.y - frame.size.height - 256;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.30f];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset < 0) {
        CGRect rect = CGRectMake(0.0f, offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
    return YES;
}

@end
