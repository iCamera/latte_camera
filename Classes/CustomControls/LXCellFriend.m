//
//  luxeysCellFriend.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/6/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "LXCellFriend.h"
#import "UIImageView+loadProgress.h"
#import "LXUtils.h"

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
    
    [LXUtils globalShadow:viewBackground];
    viewBackground.layer.cornerRadius = 5.0;
    
    [super drawRect:rect];
}

@end
