//
//  luxeysTemplatePicTimeline.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/24.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "luxeysUtils.h"
#import "LatteAPIClient.h"
#import "luxeysAppDelegate.h"
#import "UIButton+AsyncImage.h"
#import "Picture.h"
#import "User.h"

@interface luxeysTemplatePicTimeline : UIViewController {
    Picture *pic;
    User *user;
    id sender;
    NSInteger section;
}

@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
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
@property (strong, nonatomic) IBOutlet UIButton *buttonShowComment;
@property (strong, nonatomic) IBOutlet UIView *viewStats;

- (id)initWithPic:(Picture *)pic user:(User *)user section:(NSInteger)section sender:(id)sender;

@end
