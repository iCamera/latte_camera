//
//  luxeysRankingViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/4/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysCellRankLv1.h"
#import "luxeysCellRankLv2.h"
#import "luxeysCellRankLv3.h"
#import "UIButton+AsyncImage.h"
#import "luxeysImageUtils.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysPicDetailViewController.h"
#import "MBProgressHUD.h"

@interface luxeysRankingViewController : UITableViewController <UIScrollViewDelegate> {
    BOOL loadEnded;
    NSString* ranktype;
    NSInteger rankpage;
    NSMutableArray *pics;
}

@property (strong, nonatomic) IBOutlet UIButton *buttonDaily;
@property (strong, nonatomic) IBOutlet UIButton *buttonWeekly;
@property (strong, nonatomic) IBOutlet UIButton *buttonMonthly;
@property (strong, nonatomic) IBOutlet UIView *viewTab;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

- (IBAction)touchTab:(UIButton*)sender;

- (void)loadRanking;
- (void)loadMore;
@end
