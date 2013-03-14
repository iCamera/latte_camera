//
//  LXCellFacebook.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/12/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "LXFacebookFriendViewController.h"

@interface LXCellFacebook : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;
@property (strong, nonatomic) IBOutlet UILabel *labelIntro;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;

- (IBAction)touchUser:(id)sender;
- (IBAction)toggleFollow:(UIButton *)sender;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) LXFacebookFriendViewController* parent;

@end
