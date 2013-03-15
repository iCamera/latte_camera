//
//  LXCollectionCellUser.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCollectionCellUser.h"
#import "LXUtils.h"
#import "UIImageView+loadProgress.h"

@implementation LXCollectionCellUser

@synthesize imageUser;
@synthesize labelName;
@synthesize labelCover;

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
    [LXUtils globalShadow:self];
    self.layer.cornerRadius = 5.0;
    labelCover.layer.cornerRadius = 5.0;
    labelCover.layer.masksToBounds = YES;
    [super drawRect:rect];
}

- (void)setUser:(User *)user {
    imageUser.image = [UIImage imageNamed:@"user.gif"];
    [imageUser loadProgess:user.profilePicture];
    labelName.text = user.name;
}


@end
