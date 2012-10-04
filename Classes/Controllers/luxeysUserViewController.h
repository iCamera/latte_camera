//
//  luxeysUserViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIButton+AsyncImage.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "luxeysCellProfile.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysCellFriend.h"
#import "LuxeysUser.h"
#import "LuxeysPicture.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

#define kTableProfile 1
#define kTableFriends 2
#define kTableVotes 3
#define kTablePicList 4
#define kTableCalendar 5
#define kTableMap 6

@interface luxeysUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate> {
    NSMutableSet *showSet;
    NSDictionary *userDict;
    NSArray *showField;
    NSArray *friends;
    NSMutableArray *photos;
    NSMutableArray *interests;
    LuxeysUser *user;
    int tableMode;
    int userID;
    NSArray *allTab;
    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL reloading;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (strong, nonatomic) IBOutlet UIButton *buttonProfile;
@property (strong, nonatomic) IBOutlet UIButton *buttonCalendar;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
@property (strong, nonatomic) IBOutlet UITableView *tableProfile;
@property (strong, nonatomic) IBOutlet UIButton *buttonVoteCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhotoCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFriendCount;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;

- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchBack:(id)sender;
- (void)setUserID:(int)aUserID;

@end
