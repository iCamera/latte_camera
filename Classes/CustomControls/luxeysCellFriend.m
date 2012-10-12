//
//  luxeysCellFriend.m
//  Latte
//
//  Created by Xuan Dung Bui on 9/6/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import "luxeysCellFriend.h"

@implementation luxeysCellFriend
@synthesize buttonUser;
@synthesize labelName;
@synthesize labelIntro;

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
    [buttonUser loadBackground:user.profilePicture];
    buttonUser.layer.cornerRadius = 3;
    buttonUser.clipsToBounds = YES;
    labelIntro.text = user.introduction;
    labelName.text = user.name;
}

@end
