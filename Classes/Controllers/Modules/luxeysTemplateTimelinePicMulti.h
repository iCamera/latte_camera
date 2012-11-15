//
//  luxeysTemplateTimelinePicMulti.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+AsyncImage.h"
#import "luxeysPicDetailViewController.h"
#import "luxeysTemplateTimlinePicMultiItem.h"
#import "User.h"
#import "Picture.h"
#import "Feed.h"


@interface luxeysTemplateTimelinePicMulti : UIViewController {
    UIViewController *sender;
    NSInteger section;
    Feed *feed;
}

@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollImage;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

- (id)initWithFeed:(Feed *)aFeed section:(NSInteger)aSection sender:(id)aSender;

@end
