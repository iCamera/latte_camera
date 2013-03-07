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
    [super drawRect:rect];
    [LXUtils globalShadow:imageUser];
}

- (void)setUser:(User *)user {
    [imageUser loadProgess:user.profilePicture];
}


@end
