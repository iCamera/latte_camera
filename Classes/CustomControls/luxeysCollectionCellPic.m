//
//  luxeysCollectionCellPic.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/12.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysCollectionCellPic.h"

@implementation luxeysCollectionCellPic

@synthesize buttonPic;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPic:(Picture *)aPic {
    buttonPic.layer.borderColor = [[UIColor whiteColor] CGColor];
    buttonPic.layer.borderWidth = 3;
    UIBezierPath *shadowPathPic = [UIBezierPath bezierPathWithRect:buttonPic.bounds];
    buttonPic.layer.masksToBounds = NO;
    buttonPic.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonPic.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    buttonPic.layer.shadowOpacity = 0.5f;
    buttonPic.layer.shadowRadius = 1.5f;
    buttonPic.layer.shadowPath = shadowPathPic.CGPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
