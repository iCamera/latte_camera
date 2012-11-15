//
//  luxeysRegisterViewController.h
//  Latte
//
//  Created by Xuan Dung Bui on 2012/11/07.
//  Copyright (c) 2012年 LUXEYS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "luxeysAppDelegate.h"
#import "luxeysTextField.h"
#import "LatteAPIClient.h"
#import "MBProgressHUD.h"

@interface luxeysRegisterViewController : UITableViewController<FBLoginViewDelegate> {
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) IBOutlet UITextField *textMail;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
@property (strong, nonatomic) IBOutlet UITextField *textName;
- (IBAction)touchBack:(id)sender;
- (IBAction)touchReg:(id)sender;
- (IBAction)touchPolicy:(id)sender;

@end
