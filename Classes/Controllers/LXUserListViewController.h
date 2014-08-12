//
//  LXFollowerViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 7/3/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXUserListViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

- (void)loadFollowerForUser:(NSInteger)userId;
- (void)loadFollowingForUser:(NSInteger)userId;
@end
