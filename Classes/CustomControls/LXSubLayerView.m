//
//  LXSubLayerView.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXSubLayerView.h"

@implementation LXSubLayerView

@synthesize drawTriangle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundColor = self.backgroundColor;
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        backgroundColor = self.backgroundColor;
        self.backgroundColor = [UIColor clearColor];
        drawTriangle = true;
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextBeginPath(context);

    // CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    // CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    // CGContextAddLineToPoint(context, rect.origin.x + 16.0f, rect.origin.y + rect.size.height);
    // CGContextAddLineToPoint(context, rect.origin.x + 20.0f, rect.origin.y + rect.size.height - 5.0f);
    // CGContextAddLineToPoint(context, rect.origin.x + 24.0f, rect.origin.y + rect.size.height);
    // CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    // CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);

    // CGContextClosePath(context);
    // CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    // CGContextDrawPath(context, kCGPathFill);
    

    [backgroundColor setFill];
    UIBezierPath *aPath = [UIBezierPath bezierPath];

    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(0, 0)];

    // Draw the lines.
    [aPath addLineToPoint:CGPointMake(0, rect.size.height)];
    if (drawTriangle) {
        [aPath addLineToPoint:CGPointMake(16.0, rect.size.height)];
        [aPath addLineToPoint:CGPointMake(20.0, rect.size.height-5)];
        [aPath addLineToPoint:CGPointMake(24.0, rect.size.height)];
    }
    [aPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [aPath addLineToPoint:CGPointMake(rect.size.width, rect.origin.y)];

    [aPath closePath];
    [aPath fill];

    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.25f;
    self.layer.shadowRadius = 2.5f;
    self.layer.shadowPath = aPath.CGPath;
}

@end
