//
//  luxeysUserViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/20/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface luxeysUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *viewScroll;
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
- (IBAction)touchVoteCount:(id)sender;
- (IBAction)touchPicCount:(id)sender;
- (IBAction)touchFriendCount:(id)sender;

@property (strong, nonatomic) NSDictionary *dictUser;
@end
