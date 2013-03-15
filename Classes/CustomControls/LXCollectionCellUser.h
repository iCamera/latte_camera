//
//  LXCollectionCellUser.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"

@interface LXCollectionCellUser : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIView *labelCover;

@property (strong, nonatomic) User *user;

@end
