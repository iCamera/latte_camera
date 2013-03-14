//
//  LXCellSearchUser.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/14/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface LXCellSearchUser : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet UILabel *labelView;
@property (strong, nonatomic) IBOutlet UIButton *buttonProfile;
@property (strong, nonatomic) IBOutlet UIButton *buttonPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowing;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollower;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;

@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) User *user;
- (IBAction)touchUser:(id)sender;
- (IBAction)toggleFollow:(UIButton *)sender;

@end
