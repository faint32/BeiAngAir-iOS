//
//  UIView+BeiAng.m
//  BeiAngAir
//
//  Created by zhangbin on 8/21/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "UIView+BeiAng.h"

@implementation UIView (BeiAng)

- (UIImage *)captureIntoImage
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	UIGraphicsBeginImageContext(screenRect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextFillRect(context, screenRect);
	[self.layer renderInContext:context];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
