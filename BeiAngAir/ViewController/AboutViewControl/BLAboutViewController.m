//
//  BLAboutViewController.m
//  GeekController
//
//  Created by yang on 1/6/14.
//  Copyright (c) 2014 broadlink. All rights reserved.
//

#import "BLAboutViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "BLAppDelegate.h"
#import "BLLinkLabel.h"
#import "UIViewController+MMDrawerController.h"
#import "CustomNaviBarView.h"

@interface BLAboutViewController () <BLLinkLabelDelegate>

@end

@implementation BLAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"关于贝昂", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mm_drawerController setMaximumLeftDrawerWidth:320.0f];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
	//背景图片
    [self.view setBackgroundColor:RGB(1, 178, 249)];
    
    //左边按钮
    CGRect viewFrame = CGRectZero;
    UIImage *image = [UIImage imageNamed:@"left@2x"];
    viewFrame.origin.x = 10;
    viewFrame.origin.y = 15;
    viewFrame.size = image.size;
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:viewFrame];
    [leftBtn setBackgroundColor:[UIColor clearColor]];
    [leftBtn setImage:image forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
	
    //标题
    viewFrame.origin.x = leftBtn.frame.size.width + leftBtn.frame.origin.x;
    viewFrame.origin.y = leftBtn.frame.origin.y;
    viewFrame.size.height = leftBtn.frame.size.height;
    viewFrame.size.width = self.view.frame.size.width - (leftBtn.frame.size.width + leftBtn.frame.origin.x) * 2;
    UILabel *label = [[UILabel alloc] initWithFrame:viewFrame];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:NSLocalizedString(@"AboutTitle", nil)];
    [label setNumberOfLines:1];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:label];
	
    //图标
    viewFrame = CGRectZero;
    image = [UIImage imageNamed:@"home_logo"];
    viewFrame.origin.y = leftBtn.frame.size.height + leftBtn.frame.origin.y + 50.0f;
    viewFrame.origin.x = (self.view.frame.size.width - image.size.width) / 2.0f;
    viewFrame.size = image.size;
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [logoImageView setImage:image];
    [logoImageView.layer setCornerRadius:10.0f];
    [logoImageView.layer setMasksToBounds:YES];
    [self.view addSubview:logoImageView];
    
    //服务电话
    viewFrame.origin.x = 0;
    viewFrame.origin.y = self.view.frame.size.height - 140.0f - 2;
    viewFrame.size = CGSizeMake(self.view.frame.size.width, 22.0f);
    UILabel *serviceLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [serviceLabel setBackgroundColor:[UIColor clearColor]];
    [serviceLabel setText:NSLocalizedString(@"FilterInfoViewControllerServicePhoneLabel", nil)];
    [serviceLabel setTextColor:[UIColor whiteColor]];
    [serviceLabel setFont:[UIFont systemFontOfSize:13.f]];
    [serviceLabel setTextAlignment:NSTextAlignmentCenter];
    CGSize size = [serviceLabel.text sizeWithFont:[UIFont systemFontOfSize:15.f] constrainedToSize:CGSizeMake(MAXFLOAT, serviceLabel.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    viewFrame.size.width = size.width;
    [serviceLabel setFrame:viewFrame];
    [self.view addSubview:serviceLabel];
    //号码内容
    viewFrame.origin.x = serviceLabel.frame.size.width + serviceLabel.frame.origin.x;
    viewFrame.origin.y = self.view.frame.size.height - 140.0f;
    viewFrame.size = CGSizeMake(self.view.frame.size.width, 22.0f);
    BLLinkLabel *phoneLabel = [[BLLinkLabel alloc] initWithFrame:CGRectZero];
    [phoneLabel setBackgroundColor:[UIColor clearColor]];
    [phoneLabel setTextColor:[UIColor blueColor]];
    [phoneLabel setHighlightedTextColor:[UIColor grayColor]];
    [phoneLabel setDelegate:self];
    [phoneLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [phoneLabel setText:NSLocalizedString(@"FilterInfoViewControllerPhoneNumberLabel", nil)];
    [phoneLabel setTag:999 * 1];
    viewFrame = [phoneLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    [phoneLabel setFrame:viewFrame];
    [self.view addSubview:phoneLabel];
    [serviceLabel setFrame:CGRectMake((self.view.frame.size.width - phoneLabel.frame.size.width - serviceLabel.frame.size.width) / 2.f, serviceLabel.frame.origin.y, serviceLabel.frame.size.width, serviceLabel.frame.size.height)];
    [phoneLabel setFrame:CGRectMake(serviceLabel.frame.size.width + serviceLabel.frame.origin.x, phoneLabel.frame.origin.y, phoneLabel.frame.size.width, phoneLabel.frame.size.height)];
    //公司名称
    viewFrame = phoneLabel.frame;
    viewFrame.origin.y += viewFrame.size.height + 15.0f;
    viewFrame.size = CGSizeMake(self.view.frame.size.width, 22.0f);
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [companyLabel setBackgroundColor:[UIColor clearColor]];
    [companyLabel setTextColor:[UIColor whiteColor]];
    [companyLabel setTextAlignment:NSTextAlignmentCenter];
    [companyLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [companyLabel setText:NSLocalizedString(@"FilterInfoViewControllerAddress", nil)];
    viewFrame = [companyLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.x = (self.view.frame.size.width - viewFrame.size.width) / 2.0f;
    [companyLabel setFrame:viewFrame];
    [self.view addSubview:companyLabel];
    //网址
    viewFrame = companyLabel.frame;
    viewFrame.origin.y += viewFrame.size.height + 15.0f;
    viewFrame.size = CGSizeMake(self.view.frame.size.width, 22.0f);
    BLLinkLabel *webSiteLabel = [[BLLinkLabel alloc] initWithFrame:CGRectZero];
    [webSiteLabel setDelegate:self];
    [webSiteLabel setHighlightedTextColor:[UIColor grayColor]];
    [webSiteLabel setTag:999 * 2];
    [webSiteLabel setBackgroundColor:[UIColor clearColor]];
    [webSiteLabel setTextColor:[UIColor blueColor]];
    [webSiteLabel setTextAlignment:NSTextAlignmentCenter];
    [webSiteLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [webSiteLabel setText:NSLocalizedString(@"FilterInfoViewControllerWebsiteAddress", nil)];
    viewFrame = [webSiteLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.x = (self.view.frame.size.width - viewFrame.size.width) / 2.0f;
    [webSiteLabel setFrame:viewFrame];
    [self.view addSubview:webSiteLabel];
    
    viewFrame = webSiteLabel.frame;
    viewFrame.origin.y += viewFrame.size.height + 15.0f;
    viewFrame.size = CGSizeMake(self.view.frame.size.width, 44.0f);
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [addressLabel setBackgroundColor:[UIColor clearColor]];
    [addressLabel setTextColor:[UIColor whiteColor]];
    [addressLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [addressLabel setTextAlignment:NSTextAlignmentCenter];
    [addressLabel setText:NSLocalizedString(@"FilterInfoViewControllerCompanyAddress", nil)];
    [addressLabel setNumberOfLines:2];
    viewFrame = [addressLabel textRectForBounds:viewFrame limitedToNumberOfLines:2];
    viewFrame.origin.x = (self.view.frame.size.width - viewFrame.size.width) / 2.0f;
    [addressLabel setFrame:viewFrame];
    [addressLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:addressLabel];
}

-(void)leftBtnClicked:(UIButton *)button
{
    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - BLLinkLabel Delegate
- (void)linkLabel:(BLLinkLabel *)label touchesWithTag:(NSInteger)tag
{
    if (tag == 999 * 1)
    {
        UIWebView *callWebView = [[UIWebView alloc] init];
        NSURL *url = [NSURL URLWithString:@"tel://+86-0512-62925562"];
        [callWebView loadRequest:[NSURLRequest requestWithURL:url]];
        [self.view addSubview:callWebView];
    }
    else if (tag == 999 * 2)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:label.text]];
    }
}

@end
