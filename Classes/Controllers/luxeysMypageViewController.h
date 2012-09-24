//
//  luxeysMypageViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysButtonBrown30.h"

@interface luxeysMypageViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageProfilePic;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonCalendar;

- (IBAction)touchTab:(UIButton *)sender;
- (IBAction)touchSetting:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *buttonVoteCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonPicCount;
@property (strong, nonatomic) IBOutlet UIButton *buttonFriendCount;
- (IBAction)touchVoteCount:(id)sender;
- (IBAction)touchPicCount:(id)sender;
- (IBAction)touchFriendCount:(id)sender;


@end
