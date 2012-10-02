//
//  luxeysMypageViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysButtonBrown30.h"
#import "EGORefreshTableHeaderView.h"
#import "LuxeysUser.h"

@interface luxeysMypageViewController : UITableViewController <EGORefreshTableHeaderDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageProfilePic;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;

- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchSetting:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *buttonVoteCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonPicCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFriendCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineAll;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineMe;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineFriend;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineFollow;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;


@end
