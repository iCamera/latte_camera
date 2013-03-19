//
//  LXViewHeaderMypage.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/28/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXViewHeaderMypage.h"
#import "LXMyPageViewController.h"
#import "UIButton+AsyncImage.h"

@interface LXViewHeaderMypage ()

@end

@implementation LXViewHeaderMypage

@synthesize viewStats;
@synthesize viewStatsButton;
@synthesize buttonProfilePic;
@synthesize labelNickname;
@synthesize labelLikes;
@synthesize labelView;
@synthesize buttonProfile;
@synthesize buttonPicCount;
@synthesize buttonFollowCount;
@synthesize buttonFriendCount;
@synthesize buttonTimelineAll;
@synthesize buttonTimelineCalendar;
@synthesize buttonTimelineFollow;
@synthesize buttonTimelineFriend;
@synthesize buttonTimelineMe;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [LXUtils globalShadow:viewStats];
    viewStats.layer.cornerRadius = 5.0;
    
    buttonProfilePic.layer.cornerRadius = 5;
    buttonProfilePic.clipsToBounds = YES;
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:viewStatsButton.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){5.0, 5.0}].CGPath;
    viewStatsButton.layer.mask = maskLayer;
}

- (void)setUser:(User *)user {
    [buttonProfilePic loadBackground:user.profilePicture placeholderImage:@"user.gif"];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [labelNickname.layer addAnimation:animation forKey:@"changeTextTransition"];
    [labelLikes.layer addAnimation:animation forKey:@"changeTextTransition"];
    [labelView.layer addAnimation:animation forKey:@"changeTextTransition"];
    [buttonFriendCount.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [buttonPicCount.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    [buttonFollowCount.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    labelNickname.text = user.name;
    labelLikes.text = [user.voteCount stringValue];
    labelView.text = [user.pageViews stringValue];
    [buttonPicCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
    [buttonFriendCount setTitle:[user.countFollowers stringValue] forState:UIControlStateNormal];
    [buttonFollowCount setTitle:[user.countFollows stringValue] forState:UIControlStateNormal];
    
    buttonFollowCount.enabled = [user.countFollows integerValue] > 0;
    buttonFriendCount.enabled = [user.countFollowers integerValue] > 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonTimelineCalendar:nil];
    [super viewDidUnload];
}

- (void)resetTabButton {
    buttonProfile.selected = false;
    buttonPicCount.selected = false;
    buttonFollowCount.selected = false;
    buttonFriendCount.selected = false;
}

- (void)resetTimelineButton {
    buttonTimelineAll.selected = false;
    buttonTimelineCalendar.selected = false;
    buttonTimelineFollow.selected = false;
    buttonTimelineFriend.selected = false;
    buttonTimelineMe.selected = false;
}

- (IBAction)touchTab:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [self resetTabButton];
            [_parent collapseHeader];
            [_parent touchTab:kTableProfile];
            break;
        case 2:
            [self resetTabButton];
            [self resetTimelineButton];
            buttonTimelineMe.selected = true;
            [_parent expandHeader];
            [_parent touchPhoto:kPhotoMyphoto];
            break;
        case 3:
            [self resetTabButton];
            [_parent collapseHeader];
            [_parent touchTab:kTableFollowings];
            break;
        case 4:
            [self resetTabButton];
            [_parent collapseHeader];
            [_parent touchTab:kTableFollower];
            break;
        case 5:
            [self resetTimelineButton];
            [_parent touchPhoto:kPhotoTimeline];
            break;
        case 6:
            [self resetTimelineButton];
            [_parent touchPhoto:kPhotoFriends];
            break;
        case 7:
            [self resetTimelineButton];
            [_parent touchPhoto:kPhotoFollowing];
            break;
        case 8:
            [self resetTimelineButton];
            [_parent touchPhoto:kPhotoMyphoto];
            break;
        case 9:
            [self resetTimelineButton];
            [_parent touchPhoto:kPhotoCalendar];
            break;
    }
    sender.selected = true;
}

- (IBAction)touchSetProfilePic:(id)sender {
    [_parent touchSetProfilePic];
}
@end
