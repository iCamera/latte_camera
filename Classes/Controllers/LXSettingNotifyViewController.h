//
//  LXSettingNotifyViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/4/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXSettingNotifyViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIButton *buttonMailComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonPushComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonMailLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonPushLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonMailFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonPushFollow;
- (IBAction)toggleNotify:(UIButton *)sender;

@end
