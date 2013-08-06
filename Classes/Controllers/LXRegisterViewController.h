//
//  luxeysRegisterViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/07.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXAppDelegate.h"
#import "LXTextField.h"
#import "LatteAPIClient.h"
#import "MBProgressHUD.h"

@interface LXRegisterViewController : UIViewController<FBLoginViewDelegate> {
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) IBOutlet UITextField *textMail;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
@property (strong, nonatomic) IBOutlet UITextField *textName;
@property (strong, nonatomic) IBOutlet UIView *viewText1;
@property (strong, nonatomic) IBOutlet UIView *viewText2;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)touchReg:(id)sender;
- (IBAction)touchPolicy:(id)sender;
- (IBAction)tapBackground:(id)sender;

@end
