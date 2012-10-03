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
#import "LuxeysPicture.h"
#import "MBProgressHUD.h"
#import "luxeysLatteAPIClient.h"
#import "SCImageCollectionViewItem.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysAppDelegate.h"

@interface luxeysWelcomeViewController : UIViewController<SSCollectionViewDataSource, SSCollectionViewDelegate, UIScrollViewDelegate> {
    NSMutableArray *_items;
    UIActivityIndicatorView *indicator;
    int pagephoto;
    BOOL loadEnded;
    SSCollectionView *collectionView;
}

@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonLeftMenu;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonNavRight;
@property (strong, nonatomic) UIPanGestureRecognizer *navigationBarPanGestureRecognizer;

- (IBAction)loginPressed:(id)sender;

@end
