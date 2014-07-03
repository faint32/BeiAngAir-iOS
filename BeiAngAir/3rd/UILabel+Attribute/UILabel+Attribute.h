//
//  UILabel+Attribute.h
//  efergy
//
//  Created by yang on 4/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Attribute)

- (void)AddColorText:(NSString*)actxt AColor:(UIColor*)acolor AFont:(UIFont*)afont;
- (void)appendText:(NSString *)text AColorText:(NSString*)actxt AColor:(UIColor*)acolor AFont:(UIFont*)afont;
- (void)setText:(NSString *)text AColorText:(NSString*)actxt AColor:(UIColor*)acolor AFont:(UIFont*)afont;

@end
