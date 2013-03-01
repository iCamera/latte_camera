//
//  LXViewHeaderUserPage.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/28/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXViewHeaderUserPage.h"
#import "UIImageView+loadProgress.h"

@interface LXViewHeaderUserPage ()

@end

@implementation LXViewHeaderUserPage

@synthesize imageUser;
@synthesize viewStats;
@synthesize viewStatsButton;
@synthesize labelNickname;
@synthesize buttonPhotoCount;

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
    imageUser.clipsToBounds = YES;
    imageUser.layer.cornerRadius = 5;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewStats.bounds];
    viewStats.layer.masksToBounds = NO;
    viewStats.layer.shadowColor = [UIColor blackColor].CGColor;
    viewStats.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    viewStats.layer.shadowOpacity = 0.5f;
    viewStats.layer.shadowRadius = 2.0;
    viewStats.layer.shadowPath = shadowPath.CGPath;
    viewStats.layer.cornerRadius = 5.0;
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:viewStatsButton.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){5.0, 5.0}].CGPath;
    viewStatsButton.layer.mask = maskLayer;
}

- (void)setUser:(User *)user {
    labelNickname.text = user.name;
    [buttonPhotoCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
    
    if (user.profilePicture != nil)
        [imageUser setImageWithURL:[NSURL URLWithString:user.profilePicture]];
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
        case 6:
            [_parent touchPhoto:kPhotoMyphoto];
            break;
        case 7:
            [_parent touchPhoto:kPhotoTimeline];
            break;
        case 8:
            [_parent touchPhoto:kPhotoCalendar];
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonPhotoTimeline:nil];
    [self setButtonPhotoGrid:nil];
    [self setButtonTableFollowing:nil];
    [self setButtonFollower:nil];
    [self setButtonFollow:nil];
    [self setButtonPhotoCount:nil];
    [super viewDidUnload];
}
@end
