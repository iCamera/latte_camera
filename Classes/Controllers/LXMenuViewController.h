//
//  LXMenuViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/21/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXMenuViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableViewCell *menuSearch;
@property (strong, nonatomic) IBOutlet UITableViewCell *menuFollowingTags;
@property (strong, nonatomic) IBOutlet UITableViewCell *menuLikedPhotos;
@property (strong, nonatomic) IBOutlet UITableViewCell *menuLogOut;
@property (weak, nonatomic) IBOutlet UITableViewCell *menuFeedback;
@property (strong, nonatomic) IBOutlet UITableViewCell *menuLogin;
@property (strong, nonatomic) IBOutlet UITableViewCell *menuSettings;

@property (strong, nonatomic) IBOutlet UILabel *textUsername;
@property (strong, nonatomic) IBOutlet UIButton *buttonProfilePicture;
@end
