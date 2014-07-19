//
//  LXUserProfileViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 6/23/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UAProgressView.h"

@interface LXUserProfileViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UAProgressView *imageProgress;
@property (strong, nonatomic) IBOutlet UIImageView *imageProfile;
@property (strong, nonatomic) User *user;

@end
