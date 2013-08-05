//
//  LXReportAbuseViewController.h
//  Latte camera
//
//  Created by Bui Xuan Dung on 8/5/13.
//  Copyright (c) 2013 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXTextView.h"
#import "Picture.h"

@interface LXReportAbuseViewController : UITableViewController
@property (strong, nonatomic) IBOutlet LXTextView *textComment;
@property (strong, nonatomic) IBOutlet UIImageView *imagePicture;
@property (strong, nonatomic) Picture *picture;
- (IBAction)touchReport:(id)sender;

@end
