//
//  luxeysButtonBack.m
//  Latte
//
//  Created by Xuan Dung Bui on 8/10/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysButtonBack.h"
#import "luxeysAppDelegate.h"

@implementation luxeysButtonBack

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:NSLocalizedString(@"back", @"戻る")  forState:UIControlStateNormal];
        [self setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//        [self setS]
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
        self.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16];
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
        imageOrg = [UIImage imageNamed:@"bg_back.png"];
    else
        imageOrg = [UIImage imageNamed:@"bg_back_on.png"];
    
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
