//
//  LXPicCommentViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 3/6/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Picture.h"
#import "HPGrowingTextView.h"
#import "LXButtonBrown30.h"
#import "LXGalleryViewController.h"

//#import "SideSwipeTableViewController.h"
@interface LXPicCommentViewController : UIViewController<HPGrowingTextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *growingComment;
@property (strong, nonatomic) IBOutlet LXButtonBrown30 *buttonSend;
@property (strong, nonatomic) Picture *picture;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityLoad;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewFooter;
@property (strong, nonatomic) NSMutableArray *comments;

@property (weak, nonatomic) LXGalleryViewController *parent;

- (IBAction)touchSend:(id)sender;
- (IBAction)touchReport:(id)sender;
- (IBAction)touchReply:(id)sender;

@end
