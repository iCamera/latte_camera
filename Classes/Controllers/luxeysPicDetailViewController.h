//
//  luxeysPicDetailViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/22/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "luxeysCellPicture.h"
#import "luxeysCellComment.h"
#import "luxeysAppDelegate.h"
#import "luxeysImageUtils.h"
#import "luxeysUserViewController.h"
#import "luxeysButtonBrown30.h"
#import "luxeysLatteAPIClient.h"
#import "luxeysPicInfoViewController.h"
#import "luxeysLatteAPIClient.h"
#import "LuxeysPicture.h"
#import "LuxeysUser.h"
#import "LuxeysComment.h"
#import "MBProgressHUD.h"

@class luxeysTableViewCellComment, luxeysButtonBrown30;

@interface luxeysPicDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EGORefreshTableHeaderDelegate> {
    luxeysTableViewCellPicture *cellPicInfo;
    EGORefreshTableHeaderView *refreshHeaderView;
    LuxeysPicture *pic;
    LuxeysUser *user;
    int picID;
    BOOL reloading;
    BOOL loaded;
    NSMutableArray *comments;
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
@property (strong, nonatomic) IBOutlet UIView *viewTextbox;
@property (strong, nonatomic) IBOutlet UITextField *textComment;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonSend;
@property (strong, nonatomic) IBOutlet UITableView *tablePic;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintCommentView;

- (IBAction)touchBackground:(id)sender;
- (IBAction)touchBack:(id)sender;
- (IBAction)changeText:(id)sender;
- (IBAction)touchSend:(id)sender;

- (void)setPictureID:(int)aPicID;

@end
