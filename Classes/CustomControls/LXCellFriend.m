//
//  luxeysCellFriend.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/6/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCellFriend.h"
#import "UIImageView+loadProgress.h"

@implementation LXCellFriend
@synthesize imageUser;
@synthesize labelName;
@synthesize labelIntro;
@synthesize viewBackground;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    [imageUser loadProgess:user.profilePicture];
    labelIntro.text = user.introduction;
    labelName.text = user.name;
}

- (void)drawRect:(CGRect)rect {
    imageUser.layer.cornerRadius = 3;
    imageUser.clipsToBounds = YES;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewBackground.bounds];
    viewBackground.layer.masksToBounds = NO;
    viewBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    viewBackground.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewBackground.layer.shadowOpacity = 0.5f;
    viewBackground.layer.shadowRadius = 1.5f;
    viewBackground.layer.cornerRadius = 5.0;
    
    viewBackground.layer.shadowPath = shadowPath.CGPath;
    
    
    [super drawRect:rect];
}

@end
