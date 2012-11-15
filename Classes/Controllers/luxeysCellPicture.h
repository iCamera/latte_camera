//
//  luxeysPictureViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/23/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "UIButton+AsyncImage.h"
#import "User.h"
#import "Picture.h"
#import "UIImageView+loadProgress.h"
#import "luxeysUtils.h"

@interface luxeysTableViewCellPicture : UITableViewCell {
}
@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet UIView *viewStats;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelAccess;
@property (strong, nonatomic) IBOutlet UILabel *labelComment;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonInfo;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;

- (void)setPicture:(Picture *)aPicture user:(User *)aUser;

@end
