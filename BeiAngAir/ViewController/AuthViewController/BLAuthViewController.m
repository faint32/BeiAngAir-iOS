//
//  BLAuthViewController.m
//  TCLAir
//
//  Created by yang on 4/11/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLAuthViewController.h"
#import "GlobalDefine.h"
#import "BLRegistViewController.h"
#import "BLAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "Toast+UIView.h"
#import "BLDeviceListViewController.h"

@interface BLAuthViewController () <UITextFieldDelegate>
{
    BLAppDelegate *appDelegate;
}

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation BLAuthViewController

- (void)dealloc
{
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setSaveButton:nil];
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
    
    [self.view setBackgroundColor:RGB(246.0f, 246.0f, 246.0f)];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backgroundImageView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"auth_logo@2x" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.y = 20.0f + ((IsiOS7Later) ? 20.0f : 0.0f);
    viewFrame.size = image.size;
    viewFrame.origin.x = (self.view.frame.size.width - image.size.width) * 0.5f;
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [logoImageView setBackgroundColor:[UIColor clearColor]];
    [logoImageView setImage:image];
    [self.view addSubview:logoImageView];
    
    viewFrame = logoImageView.frame;
    viewFrame.origin.x = 20.0f;
    viewFrame.origin.y += viewFrame.size.height + 50.0f;
    viewFrame.size.width = self.view.frame.size.width - 2 * 20.0f;
    viewFrame.size.height = 50.0f;
    _usernameTextField = [[UITextField alloc] initWithFrame:viewFrame];
    [_usernameTextField setBackgroundColor:[UIColor clearColor]];
    [_usernameTextField setBorderStyle:UITextBorderStyleNone];
    [_usernameTextField.layer setBorderColor:RGBA(0x00, 0x00, 0x00, 0.5f).CGColor];
    [_usernameTextField.layer setBorderWidth:1.0f];
    [_usernameTextField setTextColor:[UIColor blackColor]];
    [_usernameTextField setReturnKeyType:UIReturnKeyNext];
    [_usernameTextField setDelegate:self];
    [_usernameTextField setPlaceholder:NSLocalizedString(@"AuthViewControllerUsernamePlaceholder", nil)];
    [_usernameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_usernameTextField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_usernameTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"tcl360username"]];
    [self.view addSubview:_usernameTextField];
    
    viewFrame = _usernameTextField.frame;
    viewFrame.origin.y += viewFrame.size.height - 1.0f;
    _passwordTextField = [[UITextField alloc] initWithFrame:viewFrame];
    [_passwordTextField setBackgroundColor:[UIColor clearColor]];
    [_passwordTextField setBorderStyle:UITextBorderStyleNone];
    [_passwordTextField.layer setBorderColor:RGBA(0x00, 0x00, 0x00, 0.5f).CGColor];
    [_passwordTextField.layer setBorderWidth:1.0f];
    [_passwordTextField setTextColor:[UIColor blackColor]];
    [_passwordTextField setReturnKeyType:UIReturnKeyGo];
    [_passwordTextField setDelegate:self];
    [_passwordTextField setPlaceholder:NSLocalizedString(@"AuthViewControllerPasswordPlaceholder", nil)];
    [_passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_passwordTextField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_passwordTextField setSecureTextEntry:YES];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"tcl360savepassword"] intValue])
        [_passwordTextField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"tcl360password"]];
    [self.view addSubview:_passwordTextField];
    
    path = [[NSBundle mainBundle] pathForResource:@"check_normal@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = _passwordTextField.frame;
    viewFrame.origin.y += viewFrame.size.height + 30.0f;
    viewFrame.size.height = 25.0f;
    viewFrame.size.width = viewFrame.size.width * 0.7f;
    _saveButton = [[UIButton alloc] initWithFrame:viewFrame];
    [_saveButton setBackgroundColor:[UIColor clearColor]];
    [_saveButton setImageEdgeInsets:UIEdgeInsetsMake((viewFrame.size.height - image.size.height) * 0.5f, 0.0f, (viewFrame.size.height - image.size.height) * 0.5f, viewFrame.size.width - image.size.width)];
    [_saveButton setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource:@"check_press@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    [_saveButton setImage:image forState:UIControlStateSelected];
    [_saveButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_saveButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, image.size.width, 0.0f, 0.0f)];
    [_saveButton setTitle:NSLocalizedString(@"AuthViewControllerSavePasswordText", nil) forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_saveButton setSelected:[[[NSUserDefaults standardUserDefaults] objectForKey:@"tcl360savepassword"] intValue]];
    [self.view addSubview:_saveButton];
    
    viewFrame = _saveButton.frame;
    viewFrame.origin.x = (self.view.frame.size.width - 20.0f) - viewFrame.size.width;
    UIButton *registButton = [[UIButton alloc] initWithFrame:viewFrame];
    [registButton setBackgroundColor:[UIColor clearColor]];
    [registButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [registButton setTitleColor:RGB(0x13, 0xb3, 0x5c) forState:UIControlStateNormal];
    [registButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [registButton setTitle:NSLocalizedString(@"AuthViewControllerRegistText", nil) forState:UIControlStateNormal];
    [registButton addTarget:self action:@selector(registButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [registButton sizeToFit];
    viewFrame = registButton.frame;
    viewFrame.origin.x = self.view.frame.size.width - 20.0f - viewFrame.size.width;
    viewFrame.origin.y = _saveButton.frame.origin.y + (_saveButton.frame.size.height - viewFrame.size.height) * 0.5f;
    [registButton setFrame:viewFrame];
    [registButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.view addSubview:registButton];
    
    
    path = [[NSBundle mainBundle] pathForResource:@"btn_normal@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = _saveButton.frame;
    viewFrame.origin.y += viewFrame.size.height + 25.0f;
    viewFrame.size = image.size;
    viewFrame.size.width = _passwordTextField.frame.size.width;
    UIButton *loginButton = [[UIButton alloc] initWithFrame:viewFrame];
    [loginButton setBackgroundColor:[UIColor clearColor]];
    [loginButton setImage:image forState:UIControlStateNormal];
    [loginButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, -image.size.width, 0.0f, 0.0f)];
    [loginButton setTitle:NSLocalizedString(@"AuthViewControllerLoginText", nil) forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveButtonClicked:(UIButton *)button
{
    [button setSelected:![button isSelected]];
}

- (void)registButtonClicked:(UIButton *)button
{
    BLRegistViewController *vc = [[BLRegistViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loginButtonClicked:(UIButton *)button
{
    [[NSUserDefaults standardUserDefaults] setValue:_usernameTextField.text forKey:@"tcl360username"];
    [[NSUserDefaults standardUserDefaults] setValue:_passwordTextField.text forKey:@"tcl360password"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:_saveButton.isSelected] forKey:@"tcl360savepassword"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tcl/usr?method=login&timestamp=%lld&token=%@", LCOAL_SERVER, (uint64_t)[[NSDate date] timeIntervalSince1970], [appDelegate sha1:[NSString stringWithFormat:@"oem.broadlink.com.cn%lldtcl360", (uint64_t)[[NSDate date] timeIntervalSince1970]]]]];
        ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[@"username=" dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[_usernameTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[@"&password=" dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *pwdMD5 = [appDelegate md5_16byte:_passwordTextField.text];
        NSLog(@"md5: %@", pwdMD5);
        [postData appendData:[pwdMD5 dataUsingEncoding:NSUTF8StringEncoding]];
        [request setPostBody:postData];
        [request startSynchronous];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (request.responseStatusCode == 200)
            {
                if ([[[request.responseString objectFromJSONString] objectForKey:@"code"] intValue] == 0)
                {
                    appDelegate.username = _usernameTextField.text;
                    BLDeviceListViewController *vc = [[BLDeviceListViewController alloc] init];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [vc.navigationController.navigationBar setHidden:YES];
                    [self presentViewController:nav animated:YES completion:nil];
                }
                else
                {
                    [self.view makeToast:[[request.responseString objectFromJSONString] objectForKey:@"msg"] duration:0.8f position:@"bottom"];
                }
            }
        });
    });
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_usernameTextField])
    {
        [_passwordTextField becomeFirstResponder];
        return NO;
    }
    [self.view endEditing:YES];
    [self loginButtonClicked:nil];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
