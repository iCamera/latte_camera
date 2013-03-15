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
#import "LXGalleryViewController.h"
#import "LXButtonBrown30.h"

@interface LXRankingViewController : UITableViewController <LXGalleryViewControllerDataSource>

@property (strong, nonatomic) IBOutlet UIButton *buttonDaily;
@property (strong, nonatomic) IBOutlet UIButton *buttonWeekly;
@property (strong, nonatomic) IBOutlet UIButton *buttonMonthly;
@property (strong, nonatomic) IBOutlet UIButton *buttonCalendar;
@property (strong, nonatomic) IBOutlet UIView *viewTab;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

- (IBAction)touchTab:(UIButton*)sender;
@end
