//
//  LXFacebookFriendViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/12/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface LXFacebookFriendViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;

- (void)showUser:(User*)user;

@end
