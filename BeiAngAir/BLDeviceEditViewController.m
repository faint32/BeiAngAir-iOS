//
//  BLDeviceInfoEditViewController.m
//  TCLAir
//
//  Created by yang on 4/15/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceEditViewController.h"
#import "BLAppDelegate.h"
#import "GlobalDefine.h"
#import "UIViewController+MMDrawerController.h"
#import "JSONKit.h"
#import "BLNetwork.h"

#define TOAST_DURATION  0.8f

@interface BLDeviceEditViewController () <UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    BLAppDelegate *appDelegate;
    BLNetwork *networkAPI;
    dispatch_queue_t networkQueue;
}
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, strong) UIButton *addButton;
@end

@implementation BLDeviceEditViewController

- (void)dealloc
{
	dispatch_release(networkQueue);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"DeviceInfoEditViewControllerTitle", nil);
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationController.navigationBarHidden = NO;
    
    appDelegate = (BLAppDelegate *)[[UIApplication sharedApplication] delegate];
    networkAPI = [[BLNetwork alloc] init];
    networkQueue = dispatch_queue_create("BLDeviceInfoEditViewControllerNetworkQueue", DISPATCH_QUEUE_SERIAL);
    
    [self.view setBackgroundColor:RGB(246.0f, 246.0f, 246.0f)];
    
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = 0.0f;
    viewFrame.origin.y = 0.0f;
    viewFrame.size.width = self.view.frame.size.width;
    viewFrame.size.height = 44.0f + ((IsiOS7Later) ? 20.0f : 0.0f);
    UIView *headerView = [[UIView alloc] initWithFrame:viewFrame];
    [headerView setBackgroundColor:[UIColor whiteColor]];
//    [self.view addSubview:headerView];
    
    viewFrame = headerView.frame;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [titleLabel setTextColor:RGB(0x13, 0xb3, 0x5c)];
    [titleLabel setText:NSLocalizedString(@"DeviceInfoEditViewControllerTitle", nil)];
    viewFrame = [titleLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.x = (headerView.frame.size.width - viewFrame.size.width) * 0.5f;
    viewFrame.origin.y = (44.0f - viewFrame.size.height) * 0.5f + ((IsiOS7Later) ? 20.0f : 0.0f);
    [titleLabel setFrame:viewFrame];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [headerView addSubview:titleLabel];//TODO: hide

	//TODO:
//    UIImage *image = [UIImage imageNamed:@"left"];
//    viewFrame = CGRectZero;
//    viewFrame.origin.x = 10.0f;
//    viewFrame.size = image.size;
//    viewFrame.origin.y = ((IsiOS7Later) ? 20.0f : 0.0f) + (44.0f - image.size.height) * 0.5f;
//    UIButton *backButton = [[UIButton alloc] initWithFrame:viewFrame];
//    [backButton setBackgroundColor:[UIColor clearColor]];
//    [backButton setImage:image forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [headerView addSubview:backButton];
	
	UIImage *image = [self.device avatar];
    viewFrame = headerView.frame;
    viewFrame.origin.y += viewFrame.size.height + 20.0f;
    viewFrame.origin.x = (self.view.frame.size.width - 62.5) * 0.5f;
    viewFrame.size.width = 62.5;
    viewFrame.size.height = 62.5;
    _addButton = [[UIButton alloc] initWithFrame:viewFrame];
    [_addButton.layer setMasksToBounds:YES];
    [_addButton.layer setCornerRadius:_addButton.frame.size.width / 2.f];
    [_addButton setBackgroundColor:[UIColor clearColor]];
    [_addButton setImage:image forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(logoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
    
    viewFrame = _addButton.frame;
    viewFrame.origin.y += viewFrame.size.height + 20.0f;
    viewFrame.origin.x = 20.0f;
    viewFrame.size.width = self.view.frame.size.width - 40.0f;
    viewFrame.size.height = 50.0f;
    UIView *nameView = [[UIView alloc] initWithFrame:viewFrame];
    [nameView setBackgroundColor:[UIColor whiteColor]];
    [nameView.layer setBorderColor:RGB(0x99, 0x99, 0x99).CGColor];
    [nameView.layer setBorderWidth:1.0f];
    [self.view addSubview:nameView];
    viewFrame = nameView.frame;
    viewFrame.origin.x = 3.0f;
    viewFrame.origin.y = 0.0f;
    viewFrame.size = CGSizeMake(80.0f, nameView.frame.size.height);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [nameLabel setTextColor:RGB(0x99, 0x99, 0x99)];
    [nameLabel setText:NSLocalizedString(@"DeviceInfoEditViewControllerNameLabel", nil)];
    [nameView addSubview:nameLabel];
    viewFrame = nameLabel.frame;
    viewFrame.origin.x += viewFrame.size.width + 5.0f;
    viewFrame.size = CGSizeMake(nameView.frame.size.width - 10.0f - viewFrame.origin.x, nameView.frame.size.height);
    _nameTextField = [[UITextField alloc] initWithFrame:viewFrame];
    [_nameTextField setBackgroundColor:[UIColor clearColor]];
    [_nameTextField setBorderStyle:UITextBorderStyleNone];
    [_nameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_nameTextField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_nameTextField setFont:[UIFont systemFontOfSize:15.0f]];
    [_nameTextField setKeyboardType:UIKeyboardTypeDefault];
    [_nameTextField setDelegate:self];
    [_nameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_nameTextField setPlaceholder:NSLocalizedString(@"DeviceInfoEditViewControllerNamePlaceholder", nil)];
    [_nameTextField setAutoresizesSubviews:YES];
    [_nameTextField setReturnKeyType:UIReturnKeyDone];
    [_nameTextField setText:self.device.name];
    [_nameTextField addTarget:self action:@selector(keywindowHidden:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [nameView addSubview:_nameTextField];
    
    viewFrame = nameView.frame;
    viewFrame.origin.y += viewFrame.size.height - 1.0f;
    UIView *lockView = [[UIView alloc] initWithFrame:viewFrame];
    [lockView setBackgroundColor:[UIColor whiteColor]];
    [lockView.layer setBorderColor:RGB(0x99, 0x99, 0x99).CGColor];
    [lockView.layer setBorderWidth:1.0f];
    [self.view addSubview:lockView];
    viewFrame = lockView.frame;
    viewFrame.origin.x = 3.0f;
    viewFrame.origin.y = 0.0f;
    viewFrame.size = CGSizeMake(80.0f, lockView.frame.size.height);
    UILabel *lockLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [lockLabel setBackgroundColor:[UIColor clearColor]];
    [lockLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [lockLabel setTextColor:RGB(0x99, 0x99, 0x99)];
    [lockLabel setText:NSLocalizedString(@"DeviceInfoEditViewControllerLockLabel", nil)];
    [lockView addSubview:lockLabel];
    viewFrame = lockView.frame;
    viewFrame.origin = CGPointZero;
    image = [UIImage imageNamed:@"off"];
    _lockButton = [[UIButton alloc] initWithFrame:viewFrame];
    [_lockButton setBackgroundColor:[UIColor clearColor]];
    [_lockButton setImageEdgeInsets:UIEdgeInsetsMake((viewFrame.size.height - image.size.height) * 0.5f, viewFrame.size.width - image.size.width - 10.0f, (viewFrame.size.height - image.size.height) * 0.5f, 10.0f)];
    [_lockButton setImage:image forState:UIControlStateNormal];
    image = [UIImage imageNamed:@"on"];
    [_lockButton setImage:image forState:UIControlStateSelected];
    [_lockButton addTarget:self action:@selector(lockButtonclicked:) forControlEvents:UIControlEventTouchUpInside];
    [_lockButton setSelected:self.device.lock];
    [lockView addSubview:_lockButton];
    
    viewFrame = lockView.frame;
    viewFrame.origin.y += viewFrame.size.height + 20.0f;
    UIView *macView = [[UIView alloc] initWithFrame:viewFrame];
    [macView setBackgroundColor:[UIColor whiteColor]];
    [macView.layer setBorderColor:RGB(0x99, 0x99, 0x99).CGColor];
    [macView.layer setBorderWidth:1.0f];
    [self.view addSubview:macView];
    viewFrame = lockView.frame;
    viewFrame.origin.x = 3.0f;
    viewFrame.origin.y = 0.0f;
    viewFrame.size = CGSizeMake(80.0f, lockView.frame.size.height);
    UILabel *macLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [macLabel setBackgroundColor:[UIColor clearColor]];
    [macLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [macLabel setTextColor:RGB(0x99, 0x99, 0x99)];
    [macLabel setText:NSLocalizedString(@"DeviceInfoEditViewControllerMacLabel", nil)];
    [macView addSubview:macLabel];
    viewFrame = macLabel.frame;
    viewFrame.origin.x += viewFrame.size.width + 5.0f;
    viewFrame.size = CGSizeMake(macView.frame.size.width - 10.0f - viewFrame.origin.x, macView.frame.size.height);
    UILabel *macValueLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [macValueLabel setBackgroundColor:[UIColor clearColor]];
    [macValueLabel setTextColor:[UIColor blackColor]];
    [macValueLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [macValueLabel setText:self.device.mac];
    [macView addSubview:macValueLabel];
    
    //确定按钮
    viewFrame.origin.x = 0;
    viewFrame.origin.y = 360;
    viewFrame.size.width = self.view.bounds.size.width;
	viewFrame.size.height = 50;
	UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
	okButton.frame = viewFrame;
    [okButton setBackgroundColor:[UIColor themeBlue]];
    [okButton setTitle:NSLocalizedString(@"DeviceInfoEditViewControllerOKButton", nil) forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okButton];
}

- (void)keywindowHidden:(UITextField *)field
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

//设备图标点击
-(void)logoButtonClick
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) \
                    destructiveButtonTitle:nil \
                            otherButtonTitles:NSLocalizedString(@"take_a_photo", nil),NSLocalizedString(@"choose_from_album", nil), nil];
    [chooseImageSheet showInView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)lockButtonclicked:(UIButton *)button
{
    [button setSelected:![button isSelected]];
}

- (void)okButtonClicked:(UIButton *)button
{
    dispatch_async(networkQueue, ^{
        NSString *name = [_nameTextField text];
        [self.device setName:name];
        [self.device setLock:_lockButton.isSelected];
		NSDictionary *dictionary = [NSDictionary dictionaryDeviceUpdateWithMAC:self.device.mac name:name lock:@(self.device.lock)];
        NSData *requestData = [dictionary JSONData];
        NSData *responseData = [networkAPI requestDispatch:requestData];
        NSLog(@"[[[responseData objectFromJSONData] = %d",[[[responseData objectFromJSONData] objectForKey:@"code"] intValue]);
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
			//TODO: 这里逻辑不太对，不需要把deviceArray存到appDelegate的变量里作为全局变量来使用
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.deviceInfo = deviceInfo;
//                BLModuleInfomation *moduleInfomation = [[BLModuleInfomation alloc] init];
//                moduleInfomation.info = self.deviceInfo;
//                [sqlite insertOrUpdateModuleInfo:moduleInfomation];
//                for (int i=0; i<appDelegate.deviceArray.count; i++)
//                {
//                    BLDeviceInfo *info = [appDelegate.deviceArray objectAtIndex:i];
//                    if (info.mac == self.deviceInfo.mac)
//                    {
//                        [appDelegate.deviceArray replaceObjectAtIndex:i withObject:self.deviceInfo];
//                        break;
//                    }
//                }
//                [self dismissViewControllerAnimated:YES completion:nil];
//            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setSelected:![button isSelected]];
				[self displayHUDTitle:nil message:[[responseData objectFromJSONData] objectForKey:@"msg"] duration:1];
            });
        }
    });
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSData *data = nil;
    
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *scaleImage = [self scaleImage:originImage toScale:250.0f/originImage.size.width];
        
		if (UIImagePNGRepresentation(scaleImage) == nil) {
            data = UIImageJPEGRepresentation(scaleImage, 1);
        } else {
            data = UIImagePNGRepresentation(scaleImage);
        }
        UIImage *image = [UIImage imageWithData:data];
        [_addButton setImage:image forState:UIControlStateNormal];
		NSString *imagePath = [NSString deviceAvatarPathWithMAC:self.device.mac];
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
}

//添加图片
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	if (buttonIndex == 0) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		}
		else {
			[self displayHUDTitle:nil message:NSLocalizedString(@"DeviceInfoOpenCameraFailed", nil) duration:1];
		}
		[self presentViewController:imagePicker animated:YES completion:nil];
	} else if (buttonIndex == 1) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		} else {
			[self displayHUDTitle:nil message:NSLocalizedString(@"DeviceInfoOpenCameraFailed", nil) duration:1];
		}
		[self presentViewController:imagePicker animated:YES completion:nil];
	}
}

#pragma mark - scaleImage

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize,image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect rect = CGRectMake(0.0f, (scaledImage.size.height - scaledImage.size.width) * 0.5f, scaledImage.size.width, scaledImage.size.width);
    CGImageRef sourceImageRef = [scaledImage CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    
    return newImage;
}


@end
