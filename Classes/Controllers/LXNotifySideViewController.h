//
//  luxeysRightSideViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXGalleryViewController.h"
#import "LXTabButton.h"

@interface LXNotifySideViewController : UITableViewController<LXGalleryViewControllerDataSource>
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabAll;
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabLike;
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabComment;
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabFollow;
@property (strong, nonatomic) IBOutlet LXTabButton *buttonTabAnnouncement;
@property (weak, nonatomic) IBOutlet UILabel *labelOfficialCount;

- (IBAction)showMenu;
- (IBAction)switchTab:(UIButton *)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)showSetting:(id)sender;
- (void)reloadView;

@end
