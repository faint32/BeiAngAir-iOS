//
//  BLCustomHUD+UIWindow.m
//  e-Control
//
//  Created by yang on 1/19/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLCustomHUD+UIWindow.h"
#import "iCarousel.h"
#import <objc/runtime.h>

const char okBlockKey;
const char timeBlockKey;
const char nameBlockKey;
const char intervalBlockKey;
const char cancelBlockKey;

iCarousel *hourCarousel;
iCarousel *minuteCarousel;
iCarousel *intervalCarousel;
UITextField *nameTextField;
CGFloat maxIntervalValue;

NSInteger hudType;

enum
{
    HUD_MESSAGE = 0,
    HUD_TIMER = 1,
    HUD_NAME = 2,
    HUD_INTERVAL = 3
};

@interface UIWindow (BLCustomHUDPrivate) <iCarouselDataSource, iCarouselDelegate, UITextFieldDelegate>

//@property (nonatomic, strong) iCarousel *hourCarousel;
//@property (nonatomic, strong) iCarousel *minuteCarousel;

@end

@implementation UIWindow (BLCustomHUD)

- (void)makeBLCustomHUDMessage:(NSString *)message okBlock:(void (^)(void))okBlock cancelBlock:(void (^)(void))cancelBlock
{
    return [self makeBLCustomHUDTitleImage:[UIImage imageNamed:@"bl_custom_hud_hint.png"] message:message okBlock:okBlock cancelBlock:cancelBlock];
}

- (void)makeBLCustomHUDTitleImage:(UIImage *)image
                          message:(NSString *)message
                          okBlock:(void (^)(void))okBlock
                      cancelBlock:(void (^)(void))cancelBlock
{
    hudType = HUD_MESSAGE;
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    [bgView setTag:0xbeaf];
    [bgView setBackgroundColor:[UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:0.8f]];
    [self addSubview:bgView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_bg@2x" ofType:@"png"];
    UIImage *bgImage = [UIImage imageWithContentsOfFile:path];
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = (self.frame.size.width - bgImage.size.width) / 2.0f;
    viewFrame.origin.y = (self.frame.size.height - bgImage.size.height) / 2.0f;
    viewFrame.size = bgImage.size;
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [bgImageView setBackgroundColor:[UIColor clearColor]];
    [bgImageView setImage:bgImage];
    [bgImageView setUserInteractionEnabled:YES];
    [bgView addSubview:bgImageView];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = (bgImageView.frame.size.width - 40.0f) / 2.0f;
    viewFrame.origin.y = 5.0f;
    viewFrame.size = CGSizeMake(40.0f, 43.5f);
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [titleImageView setBackgroundColor:[UIColor clearColor]];
    [titleImageView setImage:image];
    [bgImageView addSubview:titleImageView];
    
    viewFrame = CGRectMake(15.0f, 55.0f, bgImageView.frame.size.width - 30.0f, self.frame.size.height - 120.0f);
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextColor:[UIColor whiteColor]];
    [messageLabel setText:message];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setNumberOfLines:0];
    viewFrame = [messageLabel textRectForBounds:viewFrame limitedToNumberOfLines:0];
    [messageLabel setFrame:viewFrame];
    [bgImageView addSubview:messageLabel];
    
    if (viewFrame.size.height > 70.0f)
    {
        image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(55.0f, 15.0f, 50.0f, 15.0f)];
        CGRect bgFrame = bgImageView.frame;
        bgFrame.origin.y -= (viewFrame.size.height - 70.0f) / 2.0f;
        bgFrame.size.height += viewFrame.size.height - 70.0f;
        [bgImageView setFrame:bgFrame];
        [bgImageView setImage:image];
    }
    else
    {
        viewFrame.origin.y = 45.0f + (bgImageView.frame.size.height - 105.0f - viewFrame.size.height) / 2.0f;
        [messageLabel setFrame:viewFrame];
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_btn_yes@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = CGRectZero;
    viewFrame.origin.x = 0 + 12.5f;
    viewFrame.origin.y = (bgImageView.frame.size.height - image.size.height - 12.5f);
    viewFrame.size = image.size;
    UIButton *okButton = [[UIButton alloc] initWithFrame:viewFrame];
    [okButton setBackgroundColor:[UIColor clearColor]];
    [okButton setImage:image forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:okButton];
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_btn_no@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = CGRectZero;
    viewFrame.origin.x = (bgImageView.frame.size.width - image.size.width - 12.5f);
    viewFrame.origin.y = (bgImageView.frame.size.height - image.size.height - 12.5f);
    viewFrame.size = image.size;
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:viewFrame];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setImage:image forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:cancelButton];
    
    if(okBlock != nil)
    {
        objc_setAssociatedObject(self, &okBlockKey, okBlock, OBJC_ASSOCIATION_COPY);
    }
    
    if (cancelBlock != nil)
    {
        objc_setAssociatedObject(self, &cancelBlockKey, cancelBlock, OBJC_ASSOCIATION_COPY);
    }
}


- (void)makeBLCustomHUDHour:(NSInteger)hour minute:(NSInteger)minute okBlock:(void (^)(NSInteger, NSInteger))okBlock cancelBlock:(void (^)(void))cancelBlock
{
    return [self makeBLCustomHUDTitleImage:[UIImage imageNamed:@"bl_custom_hud_timer.png"] hour:hour minute:minute okBlock:okBlock cancelBlock:cancelBlock];
}

- (void)makeBLCustomHUDTitleImage:(UIImage *)image
                             hour:(NSInteger)hour
                           minute:(NSInteger)minute
                          okBlock:(void (^)(NSInteger, NSInteger))okBlock
                      cancelBlock:(void (^)(void))cancelBlock
{
    hudType = HUD_TIMER;
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    [bgView setTag:0xbeaf];
    [bgView setBackgroundColor:[UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:0.8f]];
    [self addSubview:bgView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_bg@2x" ofType:@"png"];
    UIImage *bgImage = [UIImage imageWithContentsOfFile:path];
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = (self.frame.size.width - bgImage.size.width) / 2.0f;
    viewFrame.origin.y = (self.frame.size.height - bgImage.size.height) / 2.0f;
    viewFrame.size = bgImage.size;
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [bgImageView setBackgroundColor:[UIColor clearColor]];
    [bgImageView setImage:bgImage];
    [bgImageView setUserInteractionEnabled:YES];
    [bgView addSubview:bgImageView];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = (bgImageView.frame.size.width - 40.0f) / 2.0f;
    viewFrame.origin.y = 5.0f;
    viewFrame.size = CGSizeMake(40.0f, 43.5f);
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [titleImageView setBackgroundColor:[UIColor clearColor]];
    [titleImageView setImage:image];
    [bgImageView addSubview:titleImageView];
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_btn_yes@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = CGRectZero;
    viewFrame.origin.x = 0 + 12.5f;
    viewFrame.origin.y = (bgImageView.frame.size.height - image.size.height - 12.5f);
    viewFrame.size = image.size;
    UIButton *okButton = [[UIButton alloc] initWithFrame:viewFrame];
    [okButton setBackgroundColor:[UIColor clearColor]];
    [okButton setImage:image forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:okButton];
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_btn_no@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = CGRectZero;
    viewFrame.origin.x = (bgImageView.frame.size.width - image.size.width - 12.5f);
    viewFrame.origin.y = (bgImageView.frame.size.height - image.size.height - 12.5f);
    viewFrame.size = image.size;
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:viewFrame];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setImage:image forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:cancelButton];
    
    viewFrame = CGRectMake(15.0f, 55.0f, bgImageView.frame.size.width - 30.0f, bgImageView.frame.size.height - 120.0f);
    UIView *icarouselView = [[UIView alloc] initWithFrame:viewFrame];
    [icarouselView setBackgroundColor:[UIColor clearColor]];
    [bgImageView addSubview:icarouselView];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = (icarouselView.frame.size.width - 55.0f * 2) / 3 * 1 + 55.0f * 0;
    viewFrame.origin.y = 10.0f;
    viewFrame.size = CGSizeMake(30.0f, icarouselView.frame.size.height - 2 * 10.0f);
    hourCarousel = [[iCarousel alloc] initWithFrame:viewFrame];
    [hourCarousel setTag:100];
    [hourCarousel setBackgroundColor:[UIColor clearColor]];
    [hourCarousel setDelegate:self];
    [hourCarousel setDataSource:self];
    [hourCarousel setType:iCarouselTypeLinear];
    [hourCarousel setClipsToBounds:NO];
    [hourCarousel setVertical:YES];
    [hourCarousel setDecelerationRate:0.92f];
    [hourCarousel scrollToItemAtIndex:hour animated:NO];
    [icarouselView addSubview:hourCarousel];
    
    viewFrame = hourCarousel.frame;
    viewFrame.origin.x += viewFrame.size.width;
    viewFrame.origin.y = 0.0f;
    viewFrame.size.width = 25.0f;
    UILabel *hourLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [hourLabel setBackgroundColor:[UIColor clearColor]];
    [hourLabel setTextColor:[UIColor whiteColor]];
    [hourLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [hourLabel setText:NSLocalizedString(@"SP2TaskInfoHour", nil)];
    viewFrame = [hourLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.y = (icarouselView.frame.size.height - viewFrame.size.height) / 2.0f;
    [hourLabel setFrame:viewFrame];
    [icarouselView addSubview:hourLabel];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = (icarouselView.frame.size.width - 55.0f * 2) / 3.0f * 2 + 55.0f * 1;
    viewFrame.origin.y = 10.0f;
    viewFrame.size = CGSizeMake(30.0f, icarouselView.frame.size.height - 2 * 10.0f);
    minuteCarousel = [[iCarousel alloc] initWithFrame:viewFrame];
    [minuteCarousel setTag:200];
    [minuteCarousel setBackgroundColor:[UIColor clearColor]];
    [minuteCarousel setDelegate:self];
    [minuteCarousel setDataSource:self];
    [minuteCarousel setType:iCarouselTypeLinear];
    [minuteCarousel setClipsToBounds:NO];
    [minuteCarousel setVertical:YES];
    [minuteCarousel setDecelerationRate:0.92f];
    [minuteCarousel scrollToItemAtIndex:minute animated:NO];
    [icarouselView addSubview:minuteCarousel];
    
    viewFrame = minuteCarousel.frame;
    viewFrame.origin.x += viewFrame.size.width;
    viewFrame.origin.y = 0.0f;
    viewFrame.size.width = 25.0f;
    UILabel *minuteLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [minuteLabel setBackgroundColor:[UIColor clearColor]];
    [minuteLabel setTextColor:[UIColor whiteColor]];
    [minuteLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [minuteLabel setText:NSLocalizedString(@"SP2TaskInfoMinute", nil)];
    viewFrame = [minuteLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.y = (icarouselView.frame.size.height - viewFrame.size.height) / 2.0f;
    [minuteLabel setFrame:viewFrame];
    [icarouselView addSubview:minuteLabel];
    
    if(okBlock != nil)
    {
        objc_setAssociatedObject(self, &timeBlockKey, okBlock, OBJC_ASSOCIATION_COPY);
    }
    
    if (cancelBlock != nil)
    {
        objc_setAssociatedObject(self, &cancelBlockKey, cancelBlock, OBJC_ASSOCIATION_COPY);
    }
}


- (void)makeBLCustomHUDMessage:(NSString *)message 
                           name:(NSString *)name 
                        okBlock:(void (^)(NSString * newName))block 
                    cancelBlock:(void (^)(void))cancelBlock
{
    return [self makeBLCustomHUDTitleImage:[UIImage imageNamed:@"bl_custom_hud_hint.png"] message:message name:name okBlock:block cancelBlock:cancelBlock];
}

- (void)makeBLCustomHUDTitleImage:(UIImage *)image 
                          message:(NSString *)message 
                             name:(NSString *)name 
                          okBlock:(void (^)(NSString * newName))block 
                      cancelBlock:(void (^)(void))cancelBlock
{
    hudType = HUD_NAME;
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    [bgView setTag:0xbeaf];
    [bgView setBackgroundColor:[UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:0.8f]];
    [self addSubview:bgView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_bg@2x" ofType:@"png"];
    UIImage *bgImage = [UIImage imageWithContentsOfFile:path];
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = (self.frame.size.width - bgImage.size.width) / 2.0f;
    viewFrame.origin.y = (self.frame.size.height - bgImage.size.height) / 2.0f;
    viewFrame.size = bgImage.size;
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [bgImageView setBackgroundColor:[UIColor clearColor]];
    [bgImageView setImage:bgImage];
    [bgImageView setUserInteractionEnabled:YES];
    [bgView addSubview:bgImageView];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = (bgImageView.frame.size.width - 40.0f) / 2.0f;
    viewFrame.origin.y = 5.0f;
    viewFrame.size = CGSizeMake(40.0f, 43.5f);
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [titleImageView setBackgroundColor:[UIColor clearColor]];
    [titleImageView setImage:image];
    [bgImageView addSubview:titleImageView];
    
    viewFrame = CGRectMake(15.0f, 55.0f, bgImageView.frame.size.width - 30.0f, self.frame.size.height - 120.0f);
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setTextColor:[UIColor whiteColor]];
    [messageLabel setText:message];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [messageLabel setNumberOfLines:0];
    viewFrame = [messageLabel textRectForBounds:viewFrame limitedToNumberOfLines:0];
    [messageLabel setFrame:viewFrame];
    [bgImageView addSubview:messageLabel];
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_textfield_bg@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = messageLabel.frame;
    viewFrame.origin.x = (bgImageView.frame.size.width - (image.size.width - 40.0f)) * 0.5f;
    viewFrame.origin.y += viewFrame.size.height + 10.0f;
    viewFrame.size.width = image.size.width - 40.0f;
    viewFrame.size.height = image.size.height;
    UIImageView *textFieldBgImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [textFieldBgImageView setBackgroundColor:[UIColor clearColor]];
    [textFieldBgImageView setImage:image];
    [textFieldBgImageView setUserInteractionEnabled:YES];
    [bgImageView addSubview:textFieldBgImageView];
    
    viewFrame = textFieldBgImageView.frame;
    viewFrame.origin.x = 20.0f;
    viewFrame.origin.y = (viewFrame.size.height - 32.0f) * 0.5f;
    viewFrame.size = CGSizeMake(viewFrame.size.width - 40.0f, 32.0f);
    nameTextField = [[UITextField alloc] initWithFrame:viewFrame];
    [nameTextField setTextAlignment:NSTextAlignmentCenter];
    [nameTextField setKeyboardType:UIKeyboardTypeDefault];
    [nameTextField setReturnKeyType:UIReturnKeyDone];
    [nameTextField setDelegate:self];
    [nameTextField setTextColor:[UIColor whiteColor]];
    [nameTextField setText:name];
    [textFieldBgImageView addSubview:nameTextField];
    
    if (messageLabel.frame.size.height + textFieldBgImageView.frame.size.height + 10.0f > 70.0f)
    {
        image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(55.0f, 15.0f, 50.0f, 15.0f)];
        CGRect bgFrame = bgImageView.frame;
        bgFrame.origin.y -= (messageLabel.frame.size.height + textFieldBgImageView.frame.size.height + 10.0f - 70.0f) / 2.0f;
        bgFrame.size.height += messageLabel.frame.size.height + textFieldBgImageView.frame.size.height + 10.0f - 70.0f;
        [bgImageView setFrame:bgFrame];
        [bgImageView setImage:image];
    }
    else
    {
        viewFrame.origin.y = 45.0f + (bgImageView.frame.size.height - 105.0f - viewFrame.size.height) / 2.0f;
        [messageLabel setFrame:viewFrame];
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_btn_yes@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = CGRectZero;
    viewFrame.origin.x = 0 + 12.5f;
    viewFrame.origin.y = (bgImageView.frame.size.height - image.size.height - 12.5f);
    viewFrame.size = image.size;
    UIButton *okButton = [[UIButton alloc] initWithFrame:viewFrame];
    [okButton setBackgroundColor:[UIColor clearColor]];
    [okButton setImage:image forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:okButton];
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_btn_no@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = CGRectZero;
    viewFrame.origin.x = (bgImageView.frame.size.width - image.size.width - 12.5f);
    viewFrame.origin.y = (bgImageView.frame.size.height - image.size.height - 12.5f);
    viewFrame.size = image.size;
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:viewFrame];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setImage:image forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:cancelButton];
    
    if(block != nil)
    {
        objc_setAssociatedObject(self, &nameBlockKey, block, OBJC_ASSOCIATION_COPY);
    }
    
    if (cancelBlock != nil)
    {
        objc_setAssociatedObject(self, &cancelBlockKey, cancelBlock, OBJC_ASSOCIATION_COPY);
    }
}


- (void)makeBLCustomHUDMessage:(NSString *)message 
                      maxValue:(CGFloat)maxValue 
                      interval:(CGFloat)interval 
                       okBlock:(void (^)(CGFloat *val))okBlock 
                   cancelBlock:(void (^)(void))cancelBlock
{
    return [self makeBLCustomHUDTitleImage:[UIImage imageNamed:@"bl_custom_hud_timer.png"] message:message maxValue:maxValue interval:interval okBlock:okBlock cancelBlock:cancelBlock];
}

- (void)makeBLCustomHUDTitleImage:(UIImage *)image 
                          message:(NSString *)message 
                         maxValue:(CGFloat)maxValue 
                         interval:(CGFloat)interval
                          okBlock:(void (^)(CGFloat *val))okBlock
                      cancelBlock:(void (^)(void))cancelBlock
{
    hudType = HUD_INTERVAL;
    maxIntervalValue = maxValue;
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    [bgView setTag:0xbeaf];
    [bgView setBackgroundColor:[UIColor colorWithRed:0x40/255.0f green:0x40/255.0f blue:0x40/255.0f alpha:0.8f]];
    [self addSubview:bgView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_bg@2x" ofType:@"png"];
    UIImage *bgImage = [UIImage imageWithContentsOfFile:path];
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = (self.frame.size.width - bgImage.size.width) / 2.0f;
    viewFrame.origin.y = (self.frame.size.height - bgImage.size.height) / 2.0f;
    viewFrame.size = bgImage.size;
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [bgImageView setBackgroundColor:[UIColor clearColor]];
    [bgImageView setImage:bgImage];
    [bgImageView setUserInteractionEnabled:YES];
    [bgView addSubview:bgImageView];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = (bgImageView.frame.size.width - 40.0f) / 2.0f;
    viewFrame.origin.y = 5.0f;
    viewFrame.size = CGSizeMake(40.0f, 43.5f);
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:viewFrame];
    [titleImageView setBackgroundColor:[UIColor clearColor]];
    [titleImageView setImage:image];
    [bgImageView addSubview:titleImageView];
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_btn_yes@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = CGRectZero;
    viewFrame.origin.x = 0 + 12.5f;
    viewFrame.origin.y = (bgImageView.frame.size.height - image.size.height - 12.5f);
    viewFrame.size = image.size;
    UIButton *okButton = [[UIButton alloc] initWithFrame:viewFrame];
    [okButton setBackgroundColor:[UIColor clearColor]];
    [okButton setImage:image forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:okButton];
    
    path = [[NSBundle mainBundle] pathForResource:@"bl_custom_hud_btn_no@2x" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:path];
    viewFrame = CGRectZero;
    viewFrame.origin.x = (bgImageView.frame.size.width - image.size.width - 12.5f);
    viewFrame.origin.y = (bgImageView.frame.size.height - image.size.height - 12.5f);
    viewFrame.size = image.size;
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:viewFrame];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setImage:image forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:cancelButton];
    
    viewFrame = CGRectMake(15.0f, 55.0f, bgImageView.frame.size.width - 30.0f, bgImageView.frame.size.height - 120.0f);
    UIView *icarouselView = [[UIView alloc] initWithFrame:viewFrame];
    [icarouselView setBackgroundColor:[UIColor clearColor]];
    [bgImageView addSubview:icarouselView];
    
    viewFrame = CGRectZero;
    viewFrame.origin.x = (icarouselView.frame.size.width * 0.5f - 40.0f);
    viewFrame.origin.y = 10.0f;
    viewFrame.size = CGSizeMake(40.0f, icarouselView.frame.size.height - 2 * 10.0f);
    intervalCarousel = [[iCarousel alloc] initWithFrame:viewFrame];
    [intervalCarousel setTag:1000];
    [intervalCarousel setBackgroundColor:[UIColor clearColor]];
    [intervalCarousel setDelegate:self];
    [intervalCarousel setDataSource:self];
    [intervalCarousel setType:iCarouselTypeLinear];
    [intervalCarousel setClipsToBounds:NO];
    [intervalCarousel setVertical:YES];
    [intervalCarousel setDecelerationRate:0.92f];
    NSInteger index = (interval) / 0.5;
    NSLog(@"interval = %f, index = %d", interval, index);
    [intervalCarousel scrollToItemAtIndex:index animated:NO];
    [icarouselView addSubview:intervalCarousel];
    
    viewFrame = intervalCarousel.frame;
    viewFrame.origin.x += viewFrame.size.width;
    viewFrame.origin.y = 0.0f;
    viewFrame.size.width = 50.0f;
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [secondLabel setBackgroundColor:[UIColor clearColor]];
    [secondLabel setTextColor:[UIColor whiteColor]];
    [secondLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [secondLabel setText:NSLocalizedString(@"SP2TaskInfoSecond", nil)];
    viewFrame = [secondLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.y = (icarouselView.frame.size.height - viewFrame.size.height) / 2.0f;
    [secondLabel setFrame:viewFrame];
    [icarouselView addSubview:secondLabel];
    
    if(okBlock != nil)
    {
        objc_setAssociatedObject(self, &intervalBlockKey, okBlock, OBJC_ASSOCIATION_COPY);
    }
    
    if (cancelBlock != nil)
    {
        objc_setAssociatedObject(self, &cancelBlockKey, cancelBlock, OBJC_ASSOCIATION_COPY);
    }
}



- (void)dismiss
{
    for (UIView *view in [self subviews])
    {
        if ([view tag] == 0xbeaf)
        {
            [view removeFromSuperview];
        }
    }
}

- (void)okButtonClicked:(UIButton *)button
{
    void (^theCompletionBlock)() = objc_getAssociatedObject(self, &okBlockKey);
    void (^theTimeOkBlock)() = objc_getAssociatedObject(self, &timeBlockKey);
    void (^theNameBlock)() = objc_getAssociatedObject(self, &nameBlockKey);
    void (^theIntervalBlock)() = objc_getAssociatedObject(self, &intervalBlockKey);
    
    if(theCompletionBlock == nil && theTimeOkBlock == nil \
       && theNameBlock == nil && theIntervalBlock == nil)
    {
        [self dismiss];
        return;
    }
    
    if (theCompletionBlock && hudType == HUD_MESSAGE)
        theCompletionBlock();
    if (theTimeOkBlock && hudType == HUD_TIMER)
        theTimeOkBlock(hourCarousel.currentItemIndex, minuteCarousel.currentItemIndex);
    if (theNameBlock && hudType == HUD_NAME)
        theNameBlock(nameTextField.text);
    if (theIntervalBlock && hudType == HUD_INTERVAL)
    {
        CGFloat val = intervalCarousel.currentItemIndex * 0.5f;
        theIntervalBlock(&val);
    }
    
    [self dismiss];
}

- (void)cancelButtonClicked:(UIButton *)button
{
    void (^theCompletionBlock)() = objc_getAssociatedObject(self, &cancelBlockKey);
    
    if(theCompletionBlock == nil)
        return;
    
    theCompletionBlock();
    
    [self dismiss];
}



#pragma mark -
#pragma mark - iCarousel Datasource
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    NSUInteger count = 0;
    
    if ([carousel tag] == 100)
        count = 24;
    else if ([carousel tag] == 200)
        count = 60;
    else if ([carousel tag] == 1000)
        count = (NSUInteger)(maxIntervalValue / 0.5 + 1);
    
    return count;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    return 3;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    return 1;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        view = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, carousel.frame.size.width, carousel.frame.size.width)];
        [view setBackgroundColor:[UIColor clearColor]];
    }
    
    /*If is hourCarousel or minuteCarousel.*/
    if ([carousel tag] == 100 || [carousel tag] == 200)
    {
        [((UILabel *)view) setTextAlignment:NSTextAlignmentCenter];
        [((UILabel *)view) setFont:[UIFont systemFontOfSize:22.0f]];
        [((UILabel *)view) setTextColor:[UIColor whiteColor]];
        [((UILabel *)view) setText:[NSString stringWithFormat:@"%02lu", (unsigned long)index]];
    }
    else if ([carousel tag] == 1000)
    {
        [((UILabel *)view) setTextAlignment:NSTextAlignmentCenter];
        [((UILabel *)view) setFont:[UIFont systemFontOfSize:18.0f]];
        [((UILabel *)view) setTextColor:[UIColor whiteColor]];
        [((UILabel *)view) setText:[NSString stringWithFormat:@"%.1f", 0.5 * index]];
    }
    
    return view;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        view = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, carousel.frame.size.width, carousel.frame.size.width)];
        [view setBackgroundColor:[UIColor clearColor]];
    }
    
    /*If is hourCarousel or minuteCarousel.*/
    if ([carousel tag] == 100 || [carousel tag] == 200)
    {
        [((UILabel *)view) setTextAlignment:NSTextAlignmentCenter];
        [((UILabel *)view) setFont:[UIFont systemFontOfSize:18.0f]];
        [((UILabel *)view) setTextColor:[UIColor grayColor]];
        [((UILabel *)view) setText:[NSString stringWithFormat:@"%02lu", (unsigned long)index]];
    }
    else if ([carousel tag] == 1000)
    {
        [((UILabel *)view) setTextAlignment:NSTextAlignmentCenter];
        [((UILabel *)view) setFont:[UIFont systemFontOfSize:15.0f]];
        [((UILabel *)view) setTextColor:[UIColor grayColor]];
        [((UILabel *)view) setText:[NSString stringWithFormat:@"%.1f", 0.5 * index]];
    }
    
    return view;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return carousel.frame.size.width;
}

- (CGFloat)carousel:(iCarousel *)carousel itemAlphaForOffset:(CGFloat)offset
{
	//set opacity based on distance from camera
    return 1.0f - fminf(fmaxf(offset, 0.0f), 1.0f);
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * _carousel.itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return YES;
}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
    return YES;
}

- (void)carouselCurrentItemIndexUpdated:(iCarousel *)carousel
{
    NSInteger index2 = carousel.currentItemIndex;
    NSInteger index3 = carousel.currentItemIndex + 1;
    NSMutableArray *itemArray = (NSMutableArray *)carousel.visibleItemViews;
    UILabel *label1 = [itemArray objectAtIndex:0 % carousel.numberOfItems];
    [label1 setBackgroundColor:[UIColor clearColor]];
    UILabel *label2 = [itemArray objectAtIndex:1 % carousel.numberOfItems];
    [label2 setBackgroundColor:[UIColor clearColor]];
    UILabel *label3 = [itemArray objectAtIndex:2 % carousel.numberOfItems];
    [label3 setBackgroundColor:[UIColor clearColor]];
    
    if (index3 > (carousel.numberOfItems - 1))
    {
        label1.textColor = [UIColor grayColor];
        label2.textColor = [UIColor grayColor];
        label3.textColor = [UIColor whiteColor];
        if ([carousel tag] == 100 || [carousel tag] == 200)
        {
            label1.font = [UIFont systemFontOfSize:18.0f];
            label2.font = [UIFont systemFontOfSize:18.0f];
            label3.font = [UIFont systemFontOfSize:22.0f];
        }
        else if ([carousel tag] == 1000)
        {
            label1.font = [UIFont systemFontOfSize:15.0f];
            label2.font = [UIFont systemFontOfSize:15.0f];
            label3.font = [UIFont systemFontOfSize:18.0f];
        }
    }
    else if (index2 == 0)
    {
        label1.textColor = [UIColor whiteColor];
        label2.textColor = [UIColor grayColor];
        label3.textColor = [UIColor grayColor];
        if ([carousel tag] == 100 || [carousel tag] == 200)
        {
            label1.font = [UIFont systemFontOfSize:22.0f];
            label2.font = [UIFont systemFontOfSize:18.0f];
            label3.font = [UIFont systemFontOfSize:18.0f];
        }
        else if ([carousel tag] == 1000)
        {
            label1.font = [UIFont systemFontOfSize:18.0f];
            label2.font = [UIFont systemFontOfSize:15.0f];
            label3.font = [UIFont systemFontOfSize:15.0f];
        }
    }
    else
    {
        label1.textColor = [UIColor grayColor];
        label2.textColor = [UIColor whiteColor];
        label3.textColor = [UIColor grayColor];
        if ([carousel tag] == 100 || [carousel tag] == 200)
        {
            label1.font = [UIFont systemFontOfSize:18.0f];
            label2.font = [UIFont systemFontOfSize:22.0f];
            label3.font = [UIFont systemFontOfSize:18.0f];
        }
        else if ([carousel tag] == 1000)
        {
            label1.font = [UIFont systemFontOfSize:15.0f];
            label2.font = [UIFont systemFontOfSize:18.0f];
            label3.font = [UIFont systemFontOfSize:15.0f];
        }
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self textFieldShouldReturn:nameTextField];
}

#pragma mark -
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.30f];
    self.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    [UIView commitAnimations];
    [self endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.superview.superview.superview.frame;
    int offset = self.frame.size.height - (frame.origin.y + textField.superview.superview.frame.origin.y + textField.superview.frame.origin.y + textField.superview.frame.size.height + 256.0f);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.30f];
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    if(offset < 0)
    {
        CGRect rect = CGRectMake(0.0f, offset,width,height);
        self.frame = rect;
    }
    [UIView commitAnimations];
    return YES;
}

@end
