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
#import "LuxeysUser.h"
#import "LuxeysPicture.h"


@interface luxeysTemplateTimelinePicMulti : UIViewController {
    NSArray *pics;
    LuxeysUser *user;
    UIViewController *sender;
    NSInteger section;
}

@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollImage;

- (id)initWithPics:(NSArray *)_pics user:(LuxeysUser *)_user section:(NSInteger)_section sender:(id)_sender;

@end
