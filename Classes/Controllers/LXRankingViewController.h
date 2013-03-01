//
//  luxeysRankingViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXCellRankLv1.h"
#import "LXCellRankLv2.h"
#import "UIButton+AsyncImage.h"
#import "LXUtils.h"
#import "LatteAPIClient.h"
#import "LXPicDetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "LXGalleryViewController.h"

@interface LXRankingViewController : UITableViewController <EGORefreshTableHeaderDelegate, LXGalleryViewControllerDataSource> {
    BOOL loadEnded;
    NSString* ranktype;
    NSInteger rankpage;
    NSMutableArray *pics;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer;
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) IBOutlet UIButton *buttonDaily;
@property (strong, nonatomic) IBOutlet UIButton *buttonWeekly;
@property (strong, nonatomic) IBOutlet UIButton *buttonMonthly;
@property (strong, nonatomic) IBOutlet UIView *viewTab;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;
@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonNavLeft;

- (IBAction)touchTab:(UIButton*)sender;

- (void)loadRanking;
- (void)loadMore;
@end
