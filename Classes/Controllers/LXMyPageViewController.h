//
//  luxeysMypageViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "LXPicDetailViewController.h"
#import "LXCellFriend.h"
#import "LXUtils.h"
#import "LXCellComment.h"
#import "UIButton+AsyncImage.h"
#import "LXSettingViewController.h"
#import "LXPicInfoViewController.h"
#import "LXUserPageViewController.h"
#import "LXPicCommentViewController.h"
#import "LXPicMapViewController.h"
#import "LXButtonBrown30.h"
#import "EGORefreshTableHeaderView.h"
#import "Feed.h"
#import "User.h"
#import "Picture.h"
#import "MBProgressHUD.h"
#import "UIActionSheet+ButtonState.h"
#import "LXCellTimelineSingle.h"
#import "LXCellTimelineMulti.h"

#define kTableTimeline 1
#define kTableFriends 2
#define kTableFollowings 3
#define kTablePicList 4
#define kTableVoted 5

#define kListAll 10
#define kListMe 11
#define kListFriend 12
#define kListFollow 13

#define kModelPicture 1

@interface LXMyPageViewController : UITableViewController <EGORefreshTableHeaderDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, LXImagePickerDelegate> {
    int tableMode;
    int timelineMode;
    NSArray *allTab;
    BOOL reloading;
    BOOL endedTimeline;
    BOOL endedPic;
    BOOL endedVoted;

    BOOL isEmpty;
    int pagePic;
    int pageVote;
    NSMutableArray *feeds;
    NSMutableArray *pictures;
    NSMutableArray *votes;
    NSMutableArray *friends;
    NSMutableArray *followings;
    NSMutableDictionary *toggleSection;
    NSMutableArray *lxFeeds;
    EGORefreshTableHeaderView *refreshHeaderView;
}

@property (strong, nonatomic) IBOutlet UIButton *buttonProfilePic;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonNavLeft;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;

- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchSetting:(id)sender;
- (IBAction)touchSetProfilePic:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *buttonVoteCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonPicCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFriendCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineAll;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineMe;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineFriend;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimelineFollow;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

@property (strong, nonatomic) IBOutlet UILabel *labelTitleVote;
@property (strong, nonatomic) IBOutlet UILabel *labelTitlePicCount;
@property (strong, nonatomic) IBOutlet UILabel *labelTitleFriends;
@property (strong, nonatomic) IBOutlet UILabel *labelTitleFav;


- (Feed *)feedFromPicID:(long)picID;


@end
