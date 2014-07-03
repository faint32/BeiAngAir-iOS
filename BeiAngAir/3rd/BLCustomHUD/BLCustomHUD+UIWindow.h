//
//  BLCustomHUD+UIWindow.h
//  e-Control
//
//  Created by yang on 1/19/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (BLCustomHUD)

- (void)makeBLCustomHUDMessage:(NSString *)message 
                       okBlock:(void (^)(void))okBlock 
                   cancelBlock:(void (^)(void))cancelBlock;

- (void)makeBLCustomHUDTitleImage:(UIImage *)image
                          message:(NSString *)message
                          okBlock:(void (^)(void))okBlock
                      cancelBlock:(void (^)(void))cancelBlock;

- (void)makeBLCustomHUDHour:(NSInteger)hour 
                     minute:(NSInteger)minute 
                    okBlock:(void (^)(NSInteger, NSInteger))okBlock 
                cancelBlock:(void (^)(void))cancelBlock;

- (void)makeBLCustomHUDTitleImage:(UIImage *)image
                             hour:(NSInteger)hour
                           minute:(NSInteger)minute
                          okBlock:(void (^)(NSInteger hour, NSInteger minute))okBlock
                      cancelBlock:(void (^)(void))cancelBlock;

- (void)makeBLCustomHUDMessage:(NSString *)message 
                             name:(NSString *)name 
                          okBlock:(void (^)(NSString * newName))block 
                      cancelBlock:(void (^)(void))cancelBlock;

- (void)makeBLCustomHUDTitleImage:(UIImage *)image 
                          message:(NSString *)message 
                             name:(NSString *)name 
                          okBlock:(void (^)(NSString * newName))block 
                      cancelBlock:(void (^)(void))cancelBlock;

- (void)makeBLCustomHUDMessage:(NSString *)message 
                      maxValue:(CGFloat)maxValue 
                      interval:(CGFloat)interval 
                        okBlock:(void (^)(CGFloat *))okBlock 
                    cancelBlock:(void (^)(void))cancelBlock;

- (void)makeBLCustomHUDTitleImage:(UIImage *)image 
                          message:(NSString *)message 
                         maxValue:(CGFloat)maxValue 
                         interval:(CGFloat)interval
                          okBlock:(void (^)(CGFloat *))okBlock
                      cancelBlock:(void (^)(void))cancelBlock;

- (void)dismiss;

@end
