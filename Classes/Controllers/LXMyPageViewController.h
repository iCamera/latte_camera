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

@property (strong, nonatomic) IBOutlet UIButton *buttonTag;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

- (IBAction)showMenu;

- (IBAction)switchTab:(UIButton*)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)touchHome:(id)sender;
- (void)reloadView;

@end
