//
//  BLLinkLabel.m
//  GeekController
//
//  Created by yang on 1/4/14.
//  Copyright (c) 2014 broadlink. All rights reserved.
//

#import "BLLinkLabel.h"

@interface BLLinkLabel ()

@end

@implementation BLLinkLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUserInteractionEnabled:YES];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize fontSize = [self.text sizeWithFont:self.font forWidth:self.bounds.size.width lineBreakMode:NSLineBreakByTruncatingTail];
    
    const float *colors = CGColorGetComponents(self.textColor.CGColor);
    
    if (CGColorGetNumberOfComponents(self.textColor.CGColor) == 4)
        CGContextSetRGBStrokeColor(ctx, colors[0], colors[1], colors[2], colors[3]);
    else
        CGContextSetRGBStrokeColor(ctx, colors[0], colors[0], colors[0], colors[1]);
    
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGPoint l = CGPointMake(0, self.frame.size.height / 2.0f + fontSize.height / 2.0f);
    
    CGPoint r = CGPointMake(fontSize.width, self.frame.size.height / 2.0f + fontSize.height / 2.0f);
    
    CGContextMoveToPoint(ctx, l.x, l.y);
    CGContextAddLineToPoint(ctx, r.x, r.y);
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];
}


- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    [self setNeedsDisplay];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setHighlighted:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint points = [touch locationInView:self.superview];
    
    if (points.x <= self.frame.origin.x - 30.0f \
        || points.y <= self.frame.origin.y - 30.0f \
        || points.x >= self.frame.size.width + self.frame.origin.x + 30.0f \
        || points.y >= self.frame.size.height + self.frame.origin.y + 30.0f)
    {
        [self touchesEnded:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setHighlighted:NO];
    UITouch *touch = [touches anyObject];
    CGPoint points = [touch locationInView:self];
    
    NSLog(@"x:%f, y:%f, w:%f, h:%f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    if (points.x >= 0 \
        && points.y >= 0 \
        && points.x <= self.frame.size.width \
        && points.y <= self.frame.size.height)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(linkLabel:touchesWithTag:)])
        {
            [_delegate linkLabel:self touchesWithTag:self.tag];
        }
    }
}

@end
