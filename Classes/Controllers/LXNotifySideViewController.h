//
//  luxeysRightSideViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/17/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LXMainTabViewController.h"


@interface LXNotifySideViewController : UITableViewController

- (IBAction)showMenu;
- (IBAction)switchTab:(UISegmentedControl *)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)showSetting:(id)sender;


@end
