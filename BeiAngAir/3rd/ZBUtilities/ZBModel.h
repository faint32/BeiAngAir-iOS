//
//  ZBModel.h
//  Joy
//
//  Created by zhangbin on 7/5/14.
//  Copyright (c) 2014 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBModel : NSObject

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)multiWithAttributesArray:(NSArray *)array;

@end
