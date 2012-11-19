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
#import "LXSubLayerView.h"
#import "Comment.h"
#import "luxeysCellComment.h"

@interface luxeysCellWelcomeSingle : UITableViewCell<UITableViewDataSource, UITableViewDelegate> {
    UIViewController *viewController;
    BOOL isExpanded;
    Feed *feed;
}
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonPic;
@property (strong, nonatomic) IBOutlet UIViewController *viewController;
@property (strong, nonatomic) IBOutlet LXSubLayerView *viewStat;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UILabel *labelLike;
@property (strong, nonatomic) IBOutlet UILabel *labelComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
@property (strong, nonatomic) IBOutlet UIButton *buttonInfo;
@property (strong, nonatomic) IBOutlet LXSubLayerView *viewPic;
@property (strong, nonatomic) IBOutlet UILabel *labelAccess;
@property (strong, nonatomic) IBOutlet UITableView *tableComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonExpand;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;

@property (strong, nonatomic) Feed *feed;
@property (assign) BOOL isExpanded;

@end
