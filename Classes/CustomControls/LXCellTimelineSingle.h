//
//  luxeysCellWelcomeSingle.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/06.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "LXGalleryViewController.h"
#import "LXGradientView.h"

@interface LXCellTimelineSingle : UITableViewCell<UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonUser;
@property (strong, nonatomic) IBOutlet UIButton *buttonPic;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonInfo;
@property (strong, nonatomic) IBOutlet UIView *viewBackground;
@property (strong, nonatomic) IBOutlet UIButton *buttonShare;
@property (strong, nonatomic) IBOutlet UIImageView *imageNationality;
@property (strong, nonatomic) IBOutlet UILabel *labelDesc;
@property (strong, nonatomic) IBOutlet UIView *viewWrap;
@property (strong, nonatomic) IBOutlet LXGradientView *viewDescBg;

@property (weak, nonatomic) UIViewController<LXGalleryViewControllerDataSource> *viewController;
@property (strong, nonatomic) Feed *feed;

- (IBAction)showUser:(id)sender;
- (IBAction)showPicture:(id)sender;
- (IBAction)showComment:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)toggleLike:(id)sender;
- (IBAction)moreAction:(id)sender;

@end
