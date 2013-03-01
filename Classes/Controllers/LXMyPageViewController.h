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

@class User;

typedef enum {
    kTableProfile,
    kTablePhoto,
    kTableFollower,
    kTableFollowings,
} MypageTableMode;

typedef enum {
    kPhotoTimeline,
    kPhotoFriends,
    kPhotoFollowing,
    kPhotoMyphoto,
    kPhotoCalendar,
} MypagePhotoMode;

typedef enum {
    kTimelineAll = 10,
    kTimelineFriends = 12,
    kTimelineFollowing = 13,
} LatteTimeline;

#define kModelPicture 1

@interface LXMyPageViewController : UITableViewController <EGORefreshTableHeaderDelegate, MBProgressHUDDelegate, UIActionSheetDelegate, LXImagePickerDelegate, LXGalleryViewControllerDataSource>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

@property (strong, nonatomic) User *user;

- (void)touchTab:(MypageTableMode)mode;
- (void)touchPhoto:(MypagePhotoMode)mode;

- (void)touchSetProfilePic;
- (Feed *)feedFromPicID:(long)picID;
- (void)expandHeader;
- (void)collapseHeader;

@end
