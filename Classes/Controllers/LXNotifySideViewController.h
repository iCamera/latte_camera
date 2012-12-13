//
//  luxeysRightSideViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXAppDelegate.h"
#import "LatteAPIClient.h"
#import "LXCellFriendRequest.h"
#import "LXCellNotify.h"
#import "UIButton+AsyncImage.h"
#import "LXUserPageViewController.h"
#import "LXPicDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "User.h"
#import "Picture.h"

@interface LXNotifySideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate> {
    NSMutableArray *notifies;
    NSMutableArray *requests;
    NSMutableArray *ignores;
    NSMutableArray *fbfriends;
    
    int tableMode;
    int page;
    int limit;
    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL reloading;
}

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentTab;
@property (strong, nonatomic) IBOutlet UITableView *tableNotify;
- (IBAction)touchTab:(id)sender;

@end
