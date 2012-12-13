//
//  luxeysPicCommentViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/09/26.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "LatteAPIClient.h"
#import "LXAppDelegate.h"
#import "LXCellComment.h"
#import "LXButtonBrown30.h"
#import "Picture.h"
#import "Comment.h"
#import "User.h"
#import "Feed.h"
#import "LXUserPageViewController.h"

@interface LXPicCommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    Picture *pic;
    User *user;
    UIViewController *parent;
    NSInteger picID;
}

@property (strong, nonatomic) IBOutlet UITableView *tableComment;
@property (strong, nonatomic) IBOutlet UIImageView *viewImage;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelAuthor;
@property (strong, nonatomic) IBOutlet UIView *viewComment;
@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonSubmit;
@property (strong, nonatomic) IBOutlet UITextField *textComment;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
- (IBAction)touchClose:(id)sender;
- (IBAction)touchSubmit:(id)sender;
- (IBAction)tapBackground:(id)sender;
- (IBAction)changeText:(id)sender;

- (void)setPic:(Picture *)aPic withUser:(User *)aUser withParent:(UIViewController *)aParent;
@end
