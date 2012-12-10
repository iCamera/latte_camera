//
//  luxeysNavBar.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysNavBar.h"

@implementation luxeysNavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    UIFont *font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:22];
    self.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, UITextAttributeFont,
                                [UIColor whiteColor], UITextAttributeTextColor,
                                [NSValue valueWithCGSize:CGSizeMake(0, 1)], UITextAttributeTextShadowOffset,
                                [UIColor blackColor], UITextAttributeTextShadowColor,
                                nil];
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage *image = [UIImage imageNamed: @"bg_head.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

-(void)willMoveToWindow:(UIWindow *)newWindow{
    [super willMoveToWindow:newWindow];
    [self applyDefaultStyle];
}

- (void)applyDefaultStyle {
    // add the drop shadow    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
	self.layer.masksToBounds = NO;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.layer.shadowOpacity = 0.8f;
	self.layer.shadowRadius = 2.5f;
	self.layer.shadowPath = shadowPath.CGPath;
}

@end
