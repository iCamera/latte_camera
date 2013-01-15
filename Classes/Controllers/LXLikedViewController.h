//
//  luxeysFav2ViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/01.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"
#import "Picture.h"
#import "UIButton+AsyncImage.h"
#import "EGORefreshTableHeaderView.h"
#import "LXPicDetailViewController.h"

@interface LXLikedViewController : UITableViewController<EGORefreshTableHeaderDelegate> {
    NSMutableArray *pics;
    BOOL reloading;
    EGORefreshTableHeaderView *refreshHeaderView;
}

@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonNavRight;

@end
