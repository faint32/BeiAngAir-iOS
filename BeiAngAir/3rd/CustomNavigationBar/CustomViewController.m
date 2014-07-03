//
//  CustomViewController.m
//  CustomNavigationBarDemo
//
//  Created by jimple on 14-1-6.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import "CustomViewController.h"
#import "CustomNaviBarView.h"
#import "CustomNavigationController.h"

@interface CustomViewController ()

@property (nonatomic, readonly) CustomNaviBarView *m_viewNaviBar;

@end

@implementation CustomViewController
@synthesize m_viewNaviBar = _viewNaviBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.wantsFullScreenLayout = NO;
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.wantsFullScreenLayout = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    if (!Is4Inch && !IsiOS7Later)
    _viewNaviBar = [[CustomNaviBarView alloc] initWithFrame:Rect(0.0f, 0.0f, [CustomNaviBarView barSize].width, [CustomNaviBarView barSize].height)];
    _viewNaviBar.m_viewCtrlParent = self;
    [self.view addSubview:_viewNaviBar];
    
    if (IsiOS7Later)
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
    }
    
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"GlobalBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]]];
//    [self.view setBackgroundColor:[UIColor colorWithRed:0x34/255.0f green:0x34/255.0f blue:0x34/255.0f alpha:1.0f]];
    [self.view setBackgroundColor:RGB(237, 232, 229)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [UtilityFunc cancelPerformRequestAndNotification:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_viewNaviBar && !_viewNaviBar.hidden)
    {
        [self.view bringSubviewToFront:_viewNaviBar];
    }else{}
}

#pragma mark -

- (void)bringNaviBarToTopmost
{
    if (_viewNaviBar)
    {
        [self.view bringSubviewToFront:_viewNaviBar];
    }else{}
}

- (void)moveNaviBarCoordinateX:(NSInteger)x
{
    if (_viewNaviBar)
    {
        CGRect frame = _viewNaviBar.frame;
        frame.origin.x += x;
        [_viewNaviBar setFrame:frame];
    }
    else 
    {
        
    }
}

- (void)hideNaviBar:(BOOL)bIsHide
{
    _viewNaviBar.hidden = bIsHide;
}

- (void)setNaviBarTitle:(NSString *)strTitle
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setTitle:strTitle];
    }else{APP_ASSERT_STOP}
}

- (void)setNaviBarTitle:(NSString *)strTitle color:(UIColor *)color
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setTitle:strTitle color:color];
    }
    else
    {
        APP_ASSERT_STOP;
    }
}

- (void)setNaviBarTitleFont:(UIFont *)font
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setTitleFont:font];
    }
    else
    {
        APP_ASSERT_STOP;
    }
}

- (void)setNaviBarLeftBtn:(UIButton *)btn
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setLeftBtn:btn];
    }else{APP_ASSERT_STOP}
}

- (void)setNaviBarRightBtn:(UIButton *)btn
{
    if (_viewNaviBar)
    {
        [_viewNaviBar setRightBtn:btn];
    }else{APP_ASSERT_STOP}
}

- (void)naviBarAddCoverView:(UIView *)view
{
    if (_viewNaviBar && view)
    {
        [_viewNaviBar showCoverView:view animation:YES];
    }else{}
}

- (void)naviBarAddCoverViewOnTitleView:(UIView *)view
{
    if (_viewNaviBar && view)
    {
        [_viewNaviBar showCoverViewOnTitleView:view];
    }else{}
}

- (void)naviBarRemoveCoverView:(UIView *)view
{
    if (_viewNaviBar)
    {
        [_viewNaviBar hideCoverView:view];
    }else{}
}

// 是否可右滑返回
- (void)navigationCanDragBack:(BOOL)bCanDragBack
{
    if (self.navigationController)
    {
        [((CustomNavigationController *)(self.navigationController)) navigationCanDragBack:bCanDragBack];
    }else{}
}



@end
