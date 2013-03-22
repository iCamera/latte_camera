//
//  LXViewHeaderUserPage.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 2/28/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "LXMyPageViewController.h"

@interface LXViewHeaderUserPage : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet UIButton *buttonProfile;
@property (strong, nonatomic) IBOutlet UIButton *buttonCalendar;
@property (strong, nonatomic) IBOutlet UIButton *buttonTableFollowing;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollower;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhotoTimeline;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhotoGrid;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhotoCount;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;
@property (strong, nonatomic) IBOutlet UIView *viewStatsButton;
@property (strong, nonatomic) IBOutlet UILabel *labelLikes;
@property (strong, nonatomic) IBOutlet UILabel *labelView;
@property (strong, nonatomic) IBOutlet UIImageView *imageNationality;

@property (strong, nonatomic) User* user;
@property (strong, nonatomic) LXMyPageViewController* parent;

- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)toggleFollow:(UIButton *)sender;

@end
