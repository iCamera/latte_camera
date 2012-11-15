//
//  LXSubLayerView.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/15.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "LXSubLayerView.h"

@implementation LXSubLayerView

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
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [backgroundColor setFill];
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    // Set the starting point of the shape.
    [aPath moveToPoint:rect.origin];
    
    // Draw the lines.
    [aPath addLineToPoint:CGPointMake(rect.origin.x, rect.size.height-1)];
    [aPath addLineToPoint:CGPointMake(rect.origin.x + 16.0, rect.size.height-1)];
    [aPath addLineToPoint:CGPointMake(rect.origin.x + 20.0, rect.size.height-5)];
    [aPath addLineToPoint:CGPointMake(rect.origin.x + 24.0, rect.size.height-1)];
    [aPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    [aPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    
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
