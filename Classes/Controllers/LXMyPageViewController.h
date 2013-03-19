//
//  luxeysMypageViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXGalleryViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "LXCameraViewController.h"

typedef enum {
    kTableProfile = 1,
    kTablePhoto = 2,
    kTableFollower = 3,
    kTableFollowings = 4,
} MypageTableMode;

typedef enum {
    kPhotoTimeline,
    kPhotoFriends,
    kPhotoFollowing,
    kPhotoMyphoto,
    kPhotoCalendar,
} MypagePhotoMode;

@class User;

@interface LXMyPageViewController : UITableViewController <EGORefreshTableHeaderDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, LXImagePickerDelegate, LXGalleryViewControllerDataSource>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

@property (strong, nonatomic) User *user;
@property (assign, nonatomic) MypageTableMode tableMode;

- (void)touchTab:(MypageTableMode)mode;
- (void)touchPhoto:(MypagePhotoMode)mode;

- (void)touchSetProfilePic;
- (void)expandHeader;
- (void)collapseHeader;
- (void)reloadView;

@end
