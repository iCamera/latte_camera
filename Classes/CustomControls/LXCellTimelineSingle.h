//
//  luxeysCellWelcomeSingle.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "Picture.h"
#import "UIButton+AsyncImage.h"
#import "Comment.h"
#import "LXCellComment.h"

@interface LXCellTimelineSingle : UITableViewCell<UITableViewDataSource, UITableViewDelegate> {
    UIViewController *viewController;
    BOOL isExpanded;
}
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonPic;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
@property (strong, nonatomic) IBOutlet UIButton *buttonInfo;
@property (strong, nonatomic) IBOutlet UILabel *labelAccess;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;

@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) Feed *feed;

@end
