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

@property (strong, nonatomic) IBOutlet UIButton *buttonAnnounce;
@property (strong, nonatomic) IBOutlet UIWebView *webAnnounce;


- (IBAction)switchTab:(UISegmentedControl *)sender;
- (IBAction)touchInfo:(id)sender;
- (IBAction)refresh:(id)sender;


@end
