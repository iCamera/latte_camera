//
//  luxeysCellFriend.h
//  Latte
//
//  Created by Xuan Dung Bui on 9/6/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface LXCellFriend : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelIntro;

- (void)setUser:(User*)user;

@end
