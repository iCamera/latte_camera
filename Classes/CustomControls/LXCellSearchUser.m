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
#import "LXMyPageViewController.h"

@implementation LXCellSearchUser

@synthesize buttonUser;
@synthesize buttonFollow;
@synthesize buttonFollower;
@synthesize buttonPhoto;
@synthesize buttonFollowing;
@synthesize buttonProfile;
@synthesize labelLike;
@synthesize labelView;
@synthesize viewStats;
@synthesize viewStatsButton;
@synthesize labelName;
@synthesize imageNationality;

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

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    buttonUser.clipsToBounds = YES;
    buttonUser.layer.cornerRadius = 5;
    
    [LXUtils globalShadow:viewStats];
    viewStats.layer.cornerRadius = 5.0;
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:viewStatsButton.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){5.0, 5.0}].CGPath;
    viewStatsButton.layer.mask = maskLayer;
}

- (void)setUser:(User *)user {
    _user = user;
    
    [buttonPhoto setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
    [buttonFollower setTitle:[user.countFollowers stringValue] forState:UIControlStateNormal];
    [buttonFollowing setTitle:[user.countFollows stringValue] forState:UIControlStateNormal];
    
    buttonFollowing.enabled = [user.countFollows integerValue] > 0;
    buttonFollower.enabled = [user.countFollowers integerValue] > 0;
    
    labelLike.text = [user.voteCount stringValue];
    labelView.text = [user.pageViews stringValue];
    labelName.text = user.name;

    
    [buttonUser loadBackground:user.profilePicture placeholderImage:@"user.gif"];
    
    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil && ![user.userId isEqualToNumber:app.currentUser.userId]) {
        buttonFollow.enabled = true;
        buttonFollow.selected = user.isFollowing;
    }
    
    [LXUtils setNationalityOfUser:user forImage:imageNationality nextToLabel:labelName];
}

- (IBAction)toggleFollow:(UIButton *)sender {
    sender.selected = !sender.selected;
    _user.isFollowing = sender.selected;
    NSString *url;
    
    LXAppDelegate* app = [LXAppDelegate currentDelegate];
    
    if (_user.isFollowing) {
        url = [NSString stringWithFormat:@"user/follow/%ld", [_user.userId longValue]];
    } else {
        url = [NSString stringWithFormat:@"user/unfollow/%ld", [_user.userId longValue]];
    }
    
    [[LatteAPIClient sharedClient] POST:url
                                 parameters: [NSDictionary dictionaryWithObjectsAndKeys:[app getToken], @"token", nil]
                                    success:nil
                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        sender.selected = !sender.selected;
                                        _user.isFollowing = sender.selected;
                                        DLog(@"Something went wrong (User - follow)");
                                    }];
    
}

- (IBAction)touchProfile:(id)sender {
    [self showUser];
}

- (IBAction)touchPhoto:(id)sender {
    [self showUser];
}

- (IBAction)touchFollowing:(id)sender {
    [self showUser];
}

- (IBAction)touchFollower:(id)sender {
    [self showUser];
}

- (void)showUser {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    LXMyPageViewController *viewUserPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserPage"];
    viewUserPage.user = _user;
    [_parentNav pushViewController:viewUserPage animated:YES];

}

@end
