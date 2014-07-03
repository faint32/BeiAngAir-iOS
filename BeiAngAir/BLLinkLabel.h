//
//  BLLinkLabel.h
//  GeekController
//
//  Created by yang on 1/4/14.
//  Copyright (c) 2014 broadlink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLLinkLabelDelegate;

@interface BLLinkLabel : UILabel

@property (nonatomic, assign) id <BLLinkLabelDelegate> delegate;

@end

@protocol BLLinkLabelDelegate <NSObject>

- (void)linkLabel:(BLLinkLabel *)label touchesWithTag:(NSInteger)tag;

@end
