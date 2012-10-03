//
//  luxeysPictureViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/23/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysImageUtils.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "UIButton+AsyncImage.h"
#import "LuxeysUser.h"
#import "LuxeysPicture.h"
#import "UIImageView+AFNetworking.h"

@interface luxeysTableViewCellPicture : UITableViewCell {
}
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet UILabel *labelAccess;
@property (strong, nonatomic) IBOutlet UILabel *labelComment;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonInfo;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;

- (void)setPicture:(LuxeysPicture *)aPicture user:(LuxeysUser *)aUser;

@end
