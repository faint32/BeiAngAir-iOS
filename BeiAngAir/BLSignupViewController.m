//
//  BLSignupViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 11/24/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLSignupViewController.h"

@interface BLSignupViewController ()

@property (readwrite) UITextField *accountTextField;
@property (readwrite) UITextField *passwordTextField;
@property (readwrite) UITextField *passwordConfirmTextField;
@property (readwrite) UIButton *signupButton;

@end

@implementation BLSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBarHidden = NO;
	self.view.backgroundColor = [UIColor themeBlue];
	
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 30, 10, 30);
	CGRect frame = CGRectMake(edgeInsets.left, 120, self.view.frame.size.width - edgeInsets.left - edgeInsets.right, 40);
	_accountTextField = [[UITextField alloc] initWithFrame:frame];
	_accountTextField.placeholder = @"请输入手机号/用户名";
	_accountTextField.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_accountTextField];
	
	frame.origin.y = CGRectGetMaxY(_accountTextField.frame) + edgeInsets.bottom;
	_passwordTextField = [[UITextField alloc] initWithFrame:frame];
	_passwordTextField.placeholder = @"请输入密码";
	_passwordTextField.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_passwordTextField];
	
	frame.origin.y = CGRectGetMaxY(_passwordTextField.frame) + edgeInsets.bottom;
	_passwordConfirmTextField = [[UITextField alloc] initWithFrame:frame];
	_passwordConfirmTextField.placeholder = @"请再次输入密码";
	_passwordConfirmTextField.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_passwordConfirmTextField];
	
	frame.origin.y = CGRectGetMaxY(_passwordConfirmTextField.frame) + edgeInsets.bottom;
	_signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_signupButton.frame = frame;
	_signupButton.backgroundColor = [UIColor whiteColor];
	[_signupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_signupButton setTitle:@"注册" forState:UIControlStateNormal];
	[_signupButton addTarget:self action:@selector(signup) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_signupButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)signup {
	
}

@end
