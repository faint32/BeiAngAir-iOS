//
//  ZBModel.m
//  Joy
//
//  Created by zhangbin on 7/5/14.
//  Copyright (c) 2014 颜超. All rights reserved.
//

#import "ZBModel.h"

@implementation ZBModel

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

+ (NSArray *)multiWithAttributesArray:(NSArray *)array
{
	NSMutableArray *multi = [NSMutableArray array];
	if ([array isKindOfClass:[NSNull class]]) {
		return multi;
	}
	for (NSDictionary *attributes in array) {
		[multi addObject:[[[self class] alloc] initWithAttributes:attributes]];
	}
	return multi;
}

@end
