//
//  UILabel+Attribute.m
//  efergy
//
//  Created by yang on 4/10/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "UILabel+Attribute.h"

@implementation UILabel (Attribute)

- (void)AddColorText:(NSString*)actxt AColor:(UIColor*)acolor AFont:(UIFont*)afont
{
    UIFont *nfont = afont;
    if (afont == nil) {
        nfont = self.font;
    }
    NSString *text = [self attributedText].string;
    NSMutableAttributedString *nattrStr = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedText]];
    NSRange crange = [text rangeOfString:actxt];
    [nattrStr addAttribute:NSForegroundColorAttributeName value:acolor range:crange];
    [nattrStr addAttribute:NSFontAttributeName value:nfont range:crange];
    self.attributedText = nattrStr;
}
- (void)appendText:(NSString *)text AColorText:(NSString*)actxt AColor:(UIColor*)acolor AFont:(UIFont*)afont
{
    UIFont *lbfont = self.font;
    UIFont *nfont = afont;
    if (afont == nil) {
        nfont = self.font;
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedText]];
    NSDictionary *attrdic = [NSDictionary dictionaryWithObject:lbfont forKey:NSFontAttributeName];
    NSMutableAttributedString *nattrStr = [[NSMutableAttributedString alloc]initWithString: text attributes:attrdic];
    NSRange crange = [text rangeOfString:actxt];
    [nattrStr addAttribute:NSForegroundColorAttributeName value:acolor range:crange];
    [nattrStr addAttribute:NSFontAttributeName value:nfont range:crange];
    [attrStr appendAttributedString:nattrStr];
    self.attributedText = attrStr;
}
- (void)setText:(NSString *)text AColorText:(NSString*)actxt AColor:(UIColor*)acolor AFont:(UIFont*)afont
{
    UIFont *lbfont = self.font;
    UIFont *nfont = afont;
    if (afont == nil) {
        nfont = self.font;
    }
    NSDictionary *attrdic = [NSDictionary dictionaryWithObject:lbfont forKey:NSFontAttributeName];
    NSMutableAttributedString *nattrStr = [[NSMutableAttributedString alloc]initWithString: text attributes:attrdic];
    NSRange crange = [text rangeOfString:actxt];
    [nattrStr addAttribute:NSForegroundColorAttributeName value:acolor range:crange];
    [nattrStr addAttribute:NSFontAttributeName value:nfont range:crange];
    
    self.attributedText = nattrStr;
}

@end
