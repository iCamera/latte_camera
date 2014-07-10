//
//  luxeysMypageViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXGalleryViewController.h"
#import "LXCanvasViewController.h"

@class User;

@interface LXMyPageViewController : UITableViewController <UIActionSheetDelegate, LXImagePickerDelegate, LXGalleryViewControllerDataSource>

@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UIButton *buttonTag;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;

- (IBAction)showMenu;

- (IBAction)switchTab:(UIButton*)sender;
- (IBAction)switchTimeline:(UIButton*)sender;
- (IBAction)refresh:(id)sender;
- (void)reloadView;

@end
