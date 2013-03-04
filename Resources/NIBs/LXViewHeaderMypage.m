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
@synthesize buttonPicCount;
@synthesize buttonFollowCount;
@synthesize buttonFriendCount;

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
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewStats.bounds];
    viewStats.layer.masksToBounds = NO;
    viewStats.layer.shadowColor = [UIColor blackColor].CGColor;
    viewStats.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewStats.layer.shadowOpacity = 0.5f;
    viewStats.layer.shadowRadius = 2.0;
    viewStats.layer.shadowPath = shadowPath.CGPath;
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

- (IBAction)touchTab:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [_parent collapseHeader];
            [_parent touchTab:kTableProfile];
            break;
        case 2:
            [_parent expandHeader];
            [_parent touchTab:kTablePhoto];
            break;
        case 3:
            [_parent collapseHeader];
            [_parent touchTab:kTableFollowings];
            break;
        case 4:
            [_parent collapseHeader];
            [_parent touchTab:kTableFollower];
            break;
        case 5:
            [_parent touchPhoto:kPhotoTimeline];
            break;
        case 6:
            [_parent touchPhoto:kPhotoFriends];
            break;
        case 7:
            [_parent touchPhoto:kPhotoFollowing];
            break;
        case 8:
            [_parent touchPhoto:kPhotoMyphoto];
            break;
        case 9:
            [_parent touchPhoto:kPhotoCalendar];
            break;
    }
}

- (IBAction)touchSetProfilePic:(id)sender {
    [_parent touchSetProfilePic];
}
@end
