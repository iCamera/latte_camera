//
//  luxeysButtonOrange.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/10/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysButtonOrange.h"

@implementation luxeysButtonOrange

- (void)setButtonFont {
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = [UIColor colorWithRed:0.58 green:0.29 blue:0.07 alpha:1];
    self.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setButtonFont];
    
}

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
    UIImage *imageOrg;
    if (self.state == UIControlStateNormal)
        imageOrg = [UIImage imageNamed:@"bg_bt3.png"];
    else
        imageOrg = [UIImage imageNamed:@"bg_bt3_on.png"];
    
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
    
    [self setButtonFont];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    // Force redraw of button
    [self setNeedsDisplay];
}


@end
