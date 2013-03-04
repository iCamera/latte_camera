//
//  luxeysWelcomeViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/8/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXButtonBrown30.h"
#import "LXLoginViewController.h"
#import "Feed.h"
#import "Picture.h"
#import "LatteAPIClient.h"
#import "LXPicDetailViewController.h"
#import "LXAppDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "LXCellTimelineSingle.h"
#import "LXCellTimelineMulti.h"
#import "LXGalleryViewController.h"

typedef enum {
    kWelcomeTableTimeline,
    kWelcomeTableGrid,
} WelcomeTableMode;

@interface LXWelcomeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate, LXGalleryViewControllerDataSource> {
    NSMutableArray *feeds;
    int pagephoto;
    BOOL loadEnded;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer;
    NSInteger tableMode;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIButton *buttonGrid;
@property (strong, nonatomic) IBOutlet UIButton *buttonTimeline;
@property (strong, nonatomic) IBOutlet UITableView *tablePic;
@property (strong, nonatomic) IBOutlet UIView *viewBack;
@property (strong, nonatomic) IBOutlet UIView *viewLogin;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction)loginPressed:(id)sender;
- (IBAction)touchTab:(UIButton*)sender;
- (IBAction)touchCloseLogin:(id)sender;
- (IBAction)touchReg:(id)sender;
- (IBAction)touchLogin:(id)sender;

@end
