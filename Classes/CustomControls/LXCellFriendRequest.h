//
//  luxeysCellFriendRequest.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/20.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface LXCellFriendRequest : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *userIntro;
@property (strong, nonatomic) IBOutlet UIButton *buttonIgnore;
@property (strong, nonatomic) IBOutlet UIButton *buttonAdd;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;

- (void)setUser:(User *)user;

@end
