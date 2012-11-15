//
//  luxeysWelcomeViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/8/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysButtonBrown30.h"
#import "luxeysLoginViewController.h"
#import "Feed.h"
#import "Picture.h"
#import "MBProgressHUD.h"
#import "LatteAPIClient.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysAppDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "luxeysCellWelcomeSingle.h"
#import "luxeysCellWelcomeMulti.h"
#import "luxeysUserViewController.h"

#define kTableTimeline 1
#define kTableGrid 2

@interface luxeysWelcomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate> {
    UIActivityIndicatorView *indicator;
    NSMutableArray *feeds;
    int pagephoto;
    BOOL loadEnded;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer;
    NSInteger tableMode;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonLeftMenu;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;
@property (strong, nonatomic) IBOutlet UIButton *buttonGrid;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimeline;
@property (strong, nonatomic) IBOutlet UITableView *tablePic;
@property (strong, nonatomic) IBOutlet UIView *viewBack;
@property (strong, nonatomic) IBOutlet UIView *viewLogin;

- (IBAction)loginPressed:(id)sender;
- (IBAction)touchTab:(UIButton*)sender;
- (IBAction)touchCloseLogin:(id)sender;
- (IBAction)touchReg:(id)sender;
- (IBAction)touchLogin:(id)sender;

@end
