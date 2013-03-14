//
//  LXCellSearchUser.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/14/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellSearchUser.h"
#import "UIButton+AsyncImage.h"
#import "LXAppDelegate.h"

@implementation LXCellSearchUser

@synthesize buttonUser;
@synthesize buttonFollow;

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
    _user = user;
    [buttonUser loadBackground:user.profilePicture placeholderImage:@"user.gif"];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil && ![user.userId isEqualToNumber:app.currentUser.userId]) {
        buttonFollow.enabled = true;
        buttonFollow.selected = user.isFollowing;
    }
}

- (IBAction)touchUser:(id)sender {
    TFLog(@"Touched");
}

- (IBAction)toggleFollow:(UIButton *)sender {
    sender.selected = !sender.selected;
    _user.isFollowing = sender.selected;
    NSString *url;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    if (_user.isFollowing) {
        url = [NSString stringWithFormat:@"user/follow/%d", [_user.userId integerValue]];
    } else {
        url = [NSString stringWithFormat:@"user/unfollow/%d", [_user.userId integerValue]];
    }
    
    [[LatteAPIClient sharedClient] postPath:url
                                 parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                    success:nil
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        sender.selected = !sender.selected;
                                        _user.isFollowing = sender.selected;
                                        TFLog(@"Something went wrong (User - follow)");
                                    }];
    
}

@end
