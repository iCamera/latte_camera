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
#import "luxeysUtils.h"
#import "luxeysUserViewController.h"
#import "luxeysButtonBrown30.h"

#import "LatteAPIClient.h"
#import "luxeysPicInfoViewController.h"
#import "luxeysPicEditViewController.h"
#import "luxeysPicMapViewController.h"
#import "Picture.h"
#import "User.h"
#import "Comment.h"
#import "MBProgressHUD.h"

@class luxeysTableViewCellComment, luxeysButtonBrown30;

@interface luxeysPicDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EGORefreshTableHeaderDelegate> {
    luxeysTableViewCellPicture *cellPicInfo;
    EGORefreshTableHeaderView *refreshHeaderView;
    Picture *pic;
    User *user;
    int picID;
    BOOL reloading;
    BOOL loaded;
    NSMutableArray *comments;
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
@property (strong, nonatomic) IBOutlet UIView *viewTextbox;
@property (strong, nonatomic) IBOutlet UITextField *textComment;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonSend;
@property (strong, nonatomic) IBOutlet UITableView *tablePic;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintCommentView;
@property (strong, nonatomic) IBOutlet luxeysButtonBrown30 *buttonEdit;

- (IBAction)touchBackground:(id)sender;
- (IBAction)touchBack:(id)sender;
- (IBAction)changeText:(id)sender;
- (IBAction)touchSend:(id)sender;
- (IBAction)touchEdit:(id)sender;

- (void)setPictureID:(int)aPicID;
- (void)reloadView;

@end
