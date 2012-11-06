//
//  luxeysPicEditViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/10/11.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LatteAPIClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Picture.h"
#import "UIImageView+AFNetworking.h"

@interface luxeysPicEditViewController : UITableViewController <UIActionSheetDelegate> {
    MBProgressHUD *HUD;
    
    NSData *imageData;
    NSInteger imageStatus;
    Picture *picture;
}

@property (strong, nonatomic) IBOutlet UIButton *buttonCheckLatte;
@property (strong, nonatomic) IBOutlet UIButton *buttonCheckLibrary;
@property (strong, nonatomic) IBOutlet UIButton *buttonCheckFacebook;
@property (strong, nonatomic) IBOutlet UIButton *buttonCheckTwitter;
@property (strong, nonatomic) IBOutlet UIButton *buttonDelete;
@property (strong, nonatomic) IBOutlet UIImageView *imagePic;
@property (strong, nonatomic) IBOutlet UITextField *textTitle;
@property (strong, nonatomic) IBOutlet UITextField *textDesc;
@property (strong, nonatomic) IBOutlet UISwitch *switchGPS;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureTap;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@property (strong, nonatomic) IBOutlet UIView *viewDelete;

@property (strong, nonatomic) Picture *picture;

- (IBAction)touchPost:(id)sender;
- (IBAction)touchBack:(id)sender;
- (IBAction)touchBackground:(id)sender;
- (IBAction)touchLatte:(id)sender;
- (IBAction)switchService:(UIButton *)sender;
- (IBAction)touchDelete:(id)sender;

- (void)setData:(NSData *)aData;

@end
