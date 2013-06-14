//
//  LXViewHeaderUserPage.m
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/28/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import "LXViewHeaderUserPage.h"
#import "UIButton+AsyncImage.h"
#import "UIImageView+loadProgress.h"
#import "LXAppDelegate.h"
#import "RNBlurModalView.h"

@interface LXViewHeaderUserPage ()

@end

@implementation LXViewHeaderUserPage

@synthesize buttonUser;
@synthesize viewStats;
@synthesize viewStatsButton;
@synthesize labelNickname;
@synthesize buttonPhotoCount;
@synthesize buttonFollower;
@synthesize buttonTableFollowing;
@synthesize labelLikes;
@synthesize labelView;
@synthesize buttonFollow;
@synthesize buttonCalendar;
@synthesize buttonPhotoGrid;
@synthesize buttonPhotoTimeline;
@synthesize buttonProfile;
@synthesize imageNationality;

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
    
    labelNickname.text = user.name;
    [buttonPhotoCount setTitle:[user.countPictures stringValue] forState:UIControlStateNormal];
    [buttonFollower setTitle:[user.countFollowers stringValue] forState:UIControlStateNormal];
    [buttonTableFollowing setTitle:[user.countFollows stringValue] forState:UIControlStateNormal];
    
    buttonTableFollowing.enabled = [user.countFollows integerValue] > 0;
    buttonFollower.enabled = [user.countFollowers integerValue] > 0;
    
    labelLikes.text = [user.voteCount stringValue];
    labelView.text = [user.pageViews stringValue];
    
    if (user.profilePicture)
        [buttonUser loadBackground:user.profilePicture placeholderImage:@"user.gif"];

    LXAppDelegate *app = [LXAppDelegate currentDelegate];
    if (app.currentUser != nil && ![user.userId isEqualToNumber:app.currentUser.userId]) {
        buttonFollow.enabled = true;
        buttonFollow.selected = user.isFollowing;
    }
    [LXUtils setNationalityOfUser:user forImage:imageNationality nextToLabel:labelNickname];
}

- (void)resetPhotoButton {
    buttonPhotoGrid.selected = false;
    buttonPhotoTimeline.selected = false;
    buttonCalendar.selected = false;
}

- (void)resetTabButton {
    buttonProfile.selected = false;
    buttonTableFollowing.selected = false;
    buttonFollower.selected = false;
    buttonPhotoCount.selected = false;
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
            [_parent expandHeader];
            [_parent touchTab:kTablePhoto];
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
        case 6:
            [self resetPhotoButton];
            [_parent touchPhoto:kPhotoMyphoto];
            break;
        case 7:
            [self resetPhotoButton];
            [_parent touchPhoto:kPhotoTimeline];
            break;
        case 8:
            [self resetPhotoButton];
            _parent.currentMonth = [NSDate date];
            [_parent touchPhoto:kPhotoCalendar];
            break;
    }
    sender.selected = true;
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

- (IBAction)touchUser:(id)sender {
    UIView *wrap = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
    UIImageView *viewUserPic = [[UIImageView alloc] initWithFrame:wrap.bounds];
    viewUserPic.layer.cornerRadius = 5;
    viewUserPic.layer.masksToBounds = YES;
    viewUserPic.layer.borderWidth = 1;
    viewUserPic.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    [wrap addSubview:viewUserPic];
    [LXUtils globalShadow:wrap];
    wrap.layer.cornerRadius = 5;
    if (_user.profilePictureHi)
        [viewUserPic loadProgess:_user.profilePictureHi];
    else if (_user.profilePicture)
        [viewUserPic loadProgess:_user.profilePicture];
    else
        return;
    
    RNBlurModalView *modal = [[RNBlurModalView alloc] initWithParentView:_parent.navigationController.view view:wrap];
    [modal show];
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
    [self setButtonUser:nil];
    [super viewDidUnload];
}
@end
