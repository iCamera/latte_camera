//
//  luxeysPicEditViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import "LatteAPIClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Picture.h"
#import "LXLoginViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"
#import "LXShare.h"
#import "LXTextView.h"

@interface LXPicEditViewController : UITableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIButton *buttonDelete;
@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet LXTextView *textDesc;
@property (strong, nonatomic) IBOutlet UISwitch *switchGPS;
@property (strong, nonatomic) IBOutlet UISwitch *switchEXIF;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@property (strong, nonatomic) IBOutlet UIView *viewDelete;
@property (strong, nonatomic) IBOutlet UILabel *labelTag;

@property (strong, nonatomic) Picture *picture;
@property (strong, nonatomic) UIImage *preview;
@property (strong, nonatomic) NSData *imageData;


- (IBAction)touchPost:(id)sender;
- (IBAction)touchBack:(id)sender;
- (IBAction)touchBackground:(id)sender;
- (IBAction)touchDelete:(id)sender;

@end
