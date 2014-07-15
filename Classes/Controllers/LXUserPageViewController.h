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

@interface LXUserPageViewController : UITableViewController <UIActionSheetDelegate, LXGalleryViewControllerDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIImageView *imageCover;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowing;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollower;
@property (weak, nonatomic) IBOutlet LXTabButton *buttonTabTimeline;
@property (weak, nonatomic) IBOutlet LXTabButton *buttonTabGrid;
@property (weak, nonatomic) IBOutlet LXTabButton *buttonTabTag;
@property (weak, nonatomic) IBOutlet LXTabButton *buttonTabCalendar;
@property (strong, nonatomic) IBOutlet UILabel *labelIntro;

@property (strong, nonatomic) User *user;
@property (assign, nonatomic) NSInteger userId;

- (void)expandHeader;
- (void)collapseHeader;
- (void)reloadView;
- (IBAction)touchProfilePic:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)switchView:(UIButton*)sender;
- (IBAction)touchFollow:(id)sender;

@end
