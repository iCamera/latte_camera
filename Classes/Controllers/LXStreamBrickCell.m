//
//  LXStreamBrickCell.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 4/4/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXStreamBrickCell.h"
#import "UIButton+AFNetworking.h"

@implementation LXStreamBrickCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    
    return self;
}

- (void)awakeFromNib {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _viewBg.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:1] CGColor], nil];
    [_viewBg.layer insertSublayer:gradient atIndex:0];
    
    _buttonUser.layer.cornerRadius = 10;
    _buttonUser.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _buttonUser.layer.shouldRasterize = YES;
    
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
    self.layer.shouldRasterize = YES;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

}

- (void)setPicture:(Picture *)picture {
    _picture = picture;

    [_buttonPicture setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:picture.urlSmall] placeholderImage:nil];
    _labelView.text = [NSString stringWithFormat:@"%ld", [_picture.voteCount longValue]];
}

- (void)setUser:(User *)user {
    _user = user;
    [_buttonUser setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:user.profilePicture] placeholderImage:[UIImage imageNamed:@"user.gif"]];
    _labelUsername.text = user.name;
}

- (IBAction)touchPicture:(UIButton *)sender {
    [_delegate showPic:sender];
}

@end
