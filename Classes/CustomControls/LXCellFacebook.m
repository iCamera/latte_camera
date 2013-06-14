//
//  LXCellFacebook.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/12/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXCellFacebook.h"
#import "LXUtils.h"
#import "UIButton+AsyncImage.h"
#import "LXAppDelegate.h"

@implementation LXCellFacebook

@synthesize labelIntro;
@synthesize labelNickname;
@synthesize buttonFollow;
@synthesize buttonUser;

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

- (void)setUser:(User *)user{
    _user = user;
    labelNickname.text = user.name;
    labelIntro.text = user.introduction;
    [buttonUser loadBackground:user.profilePicture placeholderImage:@"user.gif"];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil && ![user.userId isEqualToNumber:app.currentUser.userId]) {
        buttonFollow.enabled = true;
        buttonFollow.selected = user.isFollowing;
    }
}

- (void)drawRect:(CGRect)rect{
    [LXUtils globalShadow:buttonUser];
    [super drawRect:rect];
}

- (IBAction)touchUser:(id)sender {
    [_parent showUser:_user];
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
                                        DLog(@"Something went wrong (User - follow)");
                                    }];
    
}

@end
