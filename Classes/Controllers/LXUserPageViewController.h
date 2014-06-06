//
//  luxeysMypageViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXGalleryViewController.h"


@class User;

@interface LXUserPageViewController : UITableViewController <UIActionSheetDelegate, LXGalleryViewControllerDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonUsername;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentTab;

@property (strong, nonatomic) User *user;

- (void)expandHeader;
- (void)collapseHeader;
- (void)reloadView;
- (IBAction)touchProfilePic:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)switchView:(id)sender;

@end
