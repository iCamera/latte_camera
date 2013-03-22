//
//  LXCellSearchUser.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/14/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface LXCellSearchUser : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet UILabel *labelView;
@property (strong, nonatomic) IBOutlet UIButton *buttonProfile;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowing;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollower;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet UIView *viewStatsButton;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIImageView *imageNationality;

@property (weak, nonatomic) UINavigationController *parentNav;
@property (strong, nonatomic) User *user;

- (IBAction)toggleFollow:(UIButton *)sender;
- (IBAction)touchProfile:(id)sender;
- (IBAction)touchPhoto:(id)sender;
- (IBAction)touchFollowing:(id)sender;
- (IBAction)touchFollower:(id)sender;

@end
