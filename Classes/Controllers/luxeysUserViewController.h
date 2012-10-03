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
#import "LuxeysUser.h"
#import "LuxeysPicture.h"

@interface luxeysUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableSet *showSet;
    NSDictionary *userDict;
    NSArray *showField;
    NSArray *friends;
    NSMutableArray *photos;
    LuxeysUser *user;
    int tableMode;
    int userID;
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

- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchBack:(id)sender;
- (void)setUserID:(int)aUserID;

@end
