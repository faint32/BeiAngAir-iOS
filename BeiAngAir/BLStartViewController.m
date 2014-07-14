//
//  BLStartViewController.m
//  BeiAngAir
//
//  Created by zhangbin on 7/14/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLStartViewController.h"

@interface BLStartViewController ()

@property (readwrite) UIScrollView *scrollView;

@end

@implementation BLStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
