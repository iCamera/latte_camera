//
//  LXPicCommentViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"
#import "LXButtonBrown30.h"
#import "LXGalleryViewController.h"
#import "LXTextView.h"

@class Comment;

@protocol LXPicCommentViewControllerDelegate <NSObject>

@required
- (void)showUserFromComment:(Comment*)comment;
@end

@interface LXPicCommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintInputPadding;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintTextHeight;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet LXTextView *textComment;
@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonSend;
@property (strong, nonatomic) Picture *picture;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewFooter;
@property (weak, nonatomic) IBOutlet UIImageView *imageHead;

@property (assign, nonatomic) BOOL isModal;

@property (assign, nonatomic) NSInteger commentId;

@property (weak, nonatomic) UIViewController *parent;

- (IBAction)touchSend:(id)sender;
- (IBAction)touchReport:(id)sender;
- (IBAction)touchReply:(id)sender;

@end
