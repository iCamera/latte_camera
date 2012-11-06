//
//  luxeysFav2ViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "luxeysCollectionCellPic.h"
#import "MBProgressHUD.h"
#import "Picture.h"
#import "UIButton+AsyncImage.h"
#import "EGORefreshTableHeaderView.h"
#import "luxeysPicDetailViewController.h"

@interface luxeysFav2ViewController : UITableViewController<EGORefreshTableHeaderDelegate> {
    NSMutableArray *pics;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
}

@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;

@end
