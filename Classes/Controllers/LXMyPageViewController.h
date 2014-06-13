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

- (IBAction)showMenu;
- (IBAction)showSetting:(id)sender;
- (IBAction)switchTimeline:(UISegmentedControl*)sender;
- (IBAction)refresh:(id)sender;
- (void)reloadView;

@end
