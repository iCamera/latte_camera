//
//  LXViewHeaderMypage.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/28/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "LXMyPageViewController.h"

@interface LXViewHeaderMypage : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *buttonProfilePic;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet UIView *viewStatsButton;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;
@property (strong, nonatomic) IBOutlet UILabel *labelLikes;
@property (strong, nonatomic) IBOutlet UILabel *labelView;

@property (strong, nonatomic) IBOutlet UIButton *buttonProfile;
@property (strong, nonatomic) IBOutlet UIButton *buttonPicCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFriendCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineAll;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineMe;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineFriend;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineCalendar;

@property (strong, nonatomic) User* user;
@property (strong, nonatomic) LXMyPageViewController* parent;

- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchSetProfilePic:(id)sender;

@end
