//
//  luxeysTabBar.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/14/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysTabBar.h"
#import <QuartzCore/CALayer.h>

@implementation luxeysTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage *image = [UIImage imageNamed: @"bg_bottom.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [self applyDefaultStyle];
}


- (void)applyDefaultStyle {
    // add the drop shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
	self.layer.masksToBounds = NO;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.layer.shadowOpacity = 1.0f;
	self.layer.shadowRadius = 2.5f;
	self.layer.shadowPath = shadowPath.CGPath;
}

@end
