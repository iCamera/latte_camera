//
//  luxeysTemplatePicTimeline.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "luxeysImageUtils.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "UIButton+AsyncImage.h"
#import "LuxeysPicture.h"
#import "LuxeysUser.h"

@interface luxeysTemplatePicTimeline : UIViewController {
    LuxeysPicture *pic;
    LuxeysUser *user;
    id sender;
    NSInteger section;
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
@property (strong, nonatomic) IBOutlet UIButton *buttonShowComment;

- (id)initWithPic:(LuxeysPicture *)pic user:(LuxeysUser *)user section:(NSInteger)section sender:(id)sender;

@end
