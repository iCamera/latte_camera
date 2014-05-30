//
//  LXCollectionCellUser.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import "LXCollectionCellUser.h"
#import "UIImageView+AFNetworking.h"

@implementation LXCollectionCellUser

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUser:(User *)user {
    _user = user;
    
    [_imageUser setImageWithURL:[NSURL URLWithString:_user.profilePicture]];
    _labelUser.text = user.name;
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
