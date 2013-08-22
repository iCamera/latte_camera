//
//  luxeysButtonNav.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/9/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXButtonBrown30.h"

@implementation LXButtonBrown30

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
        self.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:16];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImage *imageOrg;
    if (self.state == UIControlStateNormal)
        imageOrg = [UIImage imageNamed:@"bg_bt.png"];
    else
        imageOrg = [UIImage imageNamed:@"bg_bt_on.png"];
    
    CGRect cropLeft = CGRectMake(0, 0, (rect.size.width-5)*imageOrg.scale, imageOrg.size.height*imageOrg.scale);
    CGImageRef imageRefLeft = CGImageCreateWithImageInRect([imageOrg CGImage], cropLeft);
    UIImage *imageLeft = [UIImage imageWithCGImage:imageRefLeft
                                             scale:imageOrg.scale
                                       orientation:imageOrg.imageOrientation];
    CGImageRelease(imageRefLeft);
    
    CGRect cropRight = CGRectMake((imageOrg.size.width-5)*imageOrg.scale, 0, 5*imageOrg.scale, imageOrg.size.height*imageOrg.scale);
    CGImageRef imageRefRight = CGImageCreateWithImageInRect([imageOrg CGImage], cropRight);
    UIImage *imageRight = [UIImage imageWithCGImage:imageRefRight
                                              scale:imageOrg.scale
                                        orientation:imageOrg.imageOrientation];
    CGImageRelease(imageRefRight);
    
    [imageLeft drawAtPoint:CGPointMake(0, 0)];
    [imageRight drawAtPoint:CGPointMake(rect.size.width-5, 0)];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    // Force redraw of button
    [self setNeedsDisplay];
}

@end
