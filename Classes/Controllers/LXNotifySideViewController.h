//
//  luxeysRightSideViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"
#import "LXMainTabViewController.h"


@interface LXNotifySideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>


@property (strong, nonatomic) IBOutlet UIButton *buttonNotifyAll;
@property (strong, nonatomic) IBOutlet UIButton *buttonNotifyLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonNotifyComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonNotifyFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonAnnounce;
@property (strong, nonatomic) IBOutlet UITableView *tableNotify;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;
@property (strong, nonatomic) IBOutlet UIWebView *webAnnounce;
@property (weak, nonatomic) LXMainTabViewController *parent;
- (IBAction)touchBackground:(id)sender;
- (IBAction)switchTab:(UIButton *)sender;
- (IBAction)touchSetting:(id)sender;

@end
