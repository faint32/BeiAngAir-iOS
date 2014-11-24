//
//  BLSigninViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 11/24/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLSigninViewController.h"
#import "BLSignupViewController.h"
#import "BLAPIClient.h"
#import "BLDeviceListViewController.h"

@interface BLSigninViewController ()

@property (readwrite) UITextField *accountTextField;
@property (readwrite) UITextField *passwordTextField;
@property (readwrite) UIButton *signinButton;
@property (readwrite) UIButton *cancelButton;
@property (readwrite) UILabel *signupLabel;

@end

@implementation BLSigninViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBarHidden = NO;
	self.view.backgroundColor = [UIColor themeBlue];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard)];
	[self.view addGestureRecognizer:tap];
	
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 30, 0, 30);

	CGRect frame = CGRectMake(edgeInsets.left, 150, self.view.frame.size.width - edgeInsets.left - edgeInsets.right, 40);
	_accountTextField = [[UITextField alloc] initWithFrame:frame];
	_accountTextField.placeholder = @"请输入手机号/用户名";
	_accountTextField.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_accountTextField];
	
	frame.origin.y = CGRectGetMaxY(_accountTextField.frame) + 15;
	_passwordTextField = [[UITextField alloc] initWithFrame:frame];
	_passwordTextField.placeholder = @"请输入密码";
	_passwordTextField.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_passwordTextField];
	
	frame.origin.y = CGRectGetMaxY(_passwordTextField.frame) + 30;
	frame.size.width = 120;
	_signinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_signinButton.frame = frame;
	_signinButton.backgroundColor = [UIColor whiteColor];
	[_signinButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_signinButton setTitle:@"登录" forState:UIControlStateNormal];
	[_signinButton addTarget:self action:@selector(signin) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_signinButton];
	
	frame.origin.x = CGRectGetMaxX(_signinButton.frame) + 20;
	_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cancelButton.frame = frame;
	_cancelButton.backgroundColor = [UIColor whiteColor];
	[_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
	[_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_cancelButton];
	
	frame.origin.x = edgeInsets.left;
	frame.origin.y = CGRectGetMaxY(_cancelButton.frame) + 30;
	frame.size.width = self.view.frame.size.width - edgeInsets.left - edgeInsets.right;
	_signupLabel = [[UILabel alloc] initWithFrame:frame];
	_signupLabel.text = @"没有账号?点击注册";
	_signupLabel.textAlignment = NSTextAlignmentRight;
	_signupLabel.userInteractionEnabled = YES;
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signup)];
	[_signupLabel addGestureRecognizer:tapGestureRecognizer];
	[self.view addSubview:_signupLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)resignKeyboard {
	[self.view endEditing:YES];
}

- (void)signin {
	
	_accountTextField.text = @"18662606288";
	_passwordTextField.text = @"123456";
	if (!_accountTextField.text.length) {
		[self displayHUDTitle:@"错误" message:@"账号不能为空" duration:1];
		return;
	}
	
	if (!_passwordTextField.text.length) {
		[self displayHUDTitle:@"错误" message:@"密码不能为空" duration:1];
		return;
	}
	
	[self displayHUD:@"登录中..."];
	[[BLAPIClient shared] signinAccount:_accountTextField.text password:_passwordTextField.text withBlock:^(NSError *error) {
		[self hideHUD:YES];
		if (!error) {
			BLDeviceListViewController *deviceListViewController = [[BLDeviceListViewController alloc] initWithStyle:UITableViewStyleGrouped];
			[self.navigationController pushViewController:deviceListViewController animated:YES];
		} else {
			[self displayHUDTitle:@"错误" message:error.userInfo[BL_ERROR_MESSAGE_IDENTIFIER]];
		}
	}];
}

- (void)cancel {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)signup {
	BLSignupViewController *signupViewController = [[BLSignupViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:signupViewController animated:YES];
}

@end
