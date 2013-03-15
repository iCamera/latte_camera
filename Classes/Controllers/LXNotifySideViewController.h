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


@property (strong, nonatomic) IBOutlet UITableView *tableNotify;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;
@property (strong, nonatomic) LXMainTabViewController *parent;

@end
