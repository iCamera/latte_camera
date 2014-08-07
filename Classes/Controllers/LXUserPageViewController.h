//
//  luxeysMypageViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXGalleryViewController.h"
#import "LXTabButton.h"


@class User;

@interface LXUserPageViewController : UITableViewController <UIActionSheetDelegate, LXGalleryViewControllerDataSource, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIImageView *imageCover;
@property (weak, nonatomic) IBOutlet UIButton *buttonPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowing;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollower;
@property (weak, nonatomic) IBOutlet UIButton *buttonMore;
@property (weak, nonatomic) IBOutlet LXTabButton *buttonTabTimeline;
@property (weak, nonatomic) IBOutlet LXTabButton *buttonTabGrid;
@property (weak, nonatomic) IBOutlet LXTabButton *buttonTabTag;
@property (weak, nonatomic) IBOutlet LXTabButton *buttonTabCalendar;
@property (strong, nonatomic) IBOutlet UILabel *labelIntro;
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;

@property (strong, nonatomic) User *user;
@property (assign, nonatomic) NSInteger userId;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorLoad;

- (void)expandHeader;
- (void)collapseHeader;
- (void)reloadView;

- (IBAction)refresh:(id)sender;
- (IBAction)switchView:(UIButton*)sender;
- (IBAction)touchFollow:(id)sender;
- (IBAction)touchMore:(id)sender;
- (IBAction)touchBack:(id)sender;



@end
