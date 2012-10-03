//
//  luxeysRightSideViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysAppDelegate.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysCellFriendRequest.h"
#import "luxeysCellNotify.h"
#import "UIImageView+AFNetworking.h"
#import "luxeysUserViewController.h"
#import "luxeysPicDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "LuxeysUser.h"
#import "LuxeysPicture.h"

@interface luxeysRightSideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate> {
    NSMutableArray *notifies;
    NSMutableArray *requests;
    NSMutableArray *ignores;
    int tableMode;
    int page;
    int limit;
    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL reloading;
}

@property (strong, nonatomic) IBOutlet UITableView *tableNotify;
- (IBAction)touchTab:(id)sender;

@end
