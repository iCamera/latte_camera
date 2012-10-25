//
//  luxeysCellFriendRequest.m
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/20.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import "luxeysCellFriendRequest.h"

@implementation luxeysCellFriendRequest

@synthesize userName;
@synthesize userIntro;
@synthesize imageUser;

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
    userName.text = user.name;
    userIntro.text = user.introduction;
    
//    imageUser.layer.cornerRadius = 3;
//    imageUser.clipsToBounds = YES;
    
    [imageUser setImageWithURL:[NSURL URLWithString:user.profilePicture]];
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menu.png"]];
    [self setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_menu_on.png"]]];
}

@end
