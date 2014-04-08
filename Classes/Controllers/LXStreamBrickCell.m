//
//  LXStreamBrickCell.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXStreamBrickCell.h"
#import "UIButton+AsyncImage.h"

@implementation LXStreamBrickCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setPicture:(Picture *)picture {
    _picture = picture;
    [_buttonPicture loadBackground:picture.urlSquare];
}

- (IBAction)touchPicture:(UIButton *)sender {
}

@end
