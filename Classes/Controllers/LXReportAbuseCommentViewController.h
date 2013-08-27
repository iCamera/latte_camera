//
//  LXReportAbuseViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/5/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXTextView.h"
#import "Comment.h"

@interface LXReportAbuseCommentViewController : UITableViewController
@property (strong, nonatomic) IBOutlet LXTextView *textComment;
@property (strong, nonatomic) IBOutlet LXTextView *textOriginal;
@property (strong, nonatomic) Comment *comment;
- (IBAction)touchReport:(id)sender;

@end
