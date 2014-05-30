//
//  LXCollectionCellUser.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 5/30/14.
//  Copyright (c) 2014 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface LXCollectionCellUser : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUser;

@property (strong, nonatomic) User *user;

@end
