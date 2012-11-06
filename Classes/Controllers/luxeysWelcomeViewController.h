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
#import "Picture.h"
#import "MBProgressHUD.h"
#import "LatteAPIClient.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysAppDelegate.h"
#import "EGORefreshTableHeaderView.h"

@interface luxeysWelcomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate> {
    NSMutableArray *items;
    UIActivityIndicatorView *indicator;
    int pagephoto;
    BOOL loadEnded;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer;
}

@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonLeftMenu;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;
@property (strong, nonatomic) IBOutlet UITableView *tablePic;

- (IBAction)loginPressed:(id)sender;

@end
