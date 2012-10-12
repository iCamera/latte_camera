//
//  luxeysWelcomeViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/8/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCollectionView.h"
#import "luxeysButtonBrown30.h"
#import "luxeysLoginViewController.h"
#import "Picture.h"
#import "MBProgressHUD.h"
#import "LatteAPIClient.h"
#import "SCImageCollectionViewItem.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysAppDelegate.h"
#import "EGORefreshTableHeaderView.h"

@interface luxeysWelcomeViewController : UIViewController<SSCollectionViewDataSource, SSCollectionViewDelegate, UIScrollViewDelegate, EGORefreshTableHeaderDelegate> {
    NSMutableArray *_items;
    UIActivityIndicatorView *indicator;
    int pagephoto;
    BOOL loadEnded;
    BOOL reloading;
    SSCollectionView *collectionView;
    EGORefreshTableHeaderView *refreshHeaderView;
}

@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonLeftMenu;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;
@property (strong, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;

- (IBAction)loginPressed:(id)sender;

@end
