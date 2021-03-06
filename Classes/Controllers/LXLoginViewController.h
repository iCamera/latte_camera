//
//  luxeysLoginViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 8/7/12.
//  Copyright (c) 2012 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "User.h"
#import "MBProgressHUD.h"

@class KeychainItemWrapper;

@interface LXLoginViewController : UIViewController {
    MBProgressHUD *HUD;
    BOOL isPreload;
    BOOL isPreload2;
}

@property (strong, nonatomic) IBOutlet UITextField *textPass;
@property (strong, nonatomic) IBOutlet UITextField *textUser;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapView;
@property (strong, nonatomic) IBOutlet UIView *viewTextBox;

- (IBAction)singleTap:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)touchForgot:(id)sender;
- (IBAction)touchFacebook:(id)sender;
- (IBAction)touchTwitter:(id)sender;

@end
